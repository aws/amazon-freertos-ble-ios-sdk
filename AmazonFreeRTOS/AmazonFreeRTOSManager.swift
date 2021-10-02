import AWSIoT
import CBORCoding
import CoreBluetooth
import os.log

/// FreeRTOS manager.
public class AmazonFreeRTOSManager: NSObject {

    /// Shared instence of FreeRTOS manager.
    public static let shared = AmazonFreeRTOSManager()

    /// Enable debug messages.
    public var isDebug: Bool = false
    /// Debug messages.
    public var debugMessages = String()

    /// Service UUIDs in the advertising packets.
    public var advertisingServiceUUIDs: [CBUUID] = [AmazonFreeRTOSGattService.DeviceInfo]
    /// The FreeRTOS devices using peripheral identifier as key.
    public var devices: [UUID: AmazonFreeRTOSDevice] = [:]

    /// BLE Central Manager of the FreeRTOS manager.
    public var central: CBCentralManager?

    /// Initializes a new FreeRTOS manager.
    ///
    /// - Returns: A new FreeRTOS manager.
    override public init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

extension AmazonFreeRTOSManager {

    /// Start scan for FreeRTOS devices.
    ///
    /// - Precondition: `central` is ready and not scanning.
    public func startScanForDevices() {
        if let central = central, !central.isScanning {
            central.scanForPeripherals(withServices: advertisingServiceUUIDs, options: nil)
        }
    }

    /// Stop scan for FreeRTOS devices.
    ///
    /// - Precondition: `central` is ready and is scanning.
    public func stopScanForDevices() {
        if let central = central, central.isScanning {
            central.stopScan()
        }
    }

    /// Disconnect. Clear all contexts. Scan for FreeRTOS devices.
    public func rescanForDevices() {
        stopScanForDevices()

        for device in devices.values {
            device.disconnect()
        }
        devices.removeAll()

        startScanForDevices()
    }
}

extension AmazonFreeRTOSManager: CBCentralManagerDelegate {

    /// CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NotificationCenter.default.post(name: .afrCentralManagerDidUpdateState, object: nil)
        debugPrint("[Central] afrCentralManagerDidUpdateState: \(central.state.rawValue)")
    }

    /// CBCentralManagerDelegate
    public func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !devices.keys.contains(peripheral.identifier) {
            devices[peripheral.identifier] = AmazonFreeRTOSDevice(peripheral: peripheral)
        }
        devices[peripheral.identifier]?.advertisementData = advertisementData
        devices[peripheral.identifier]?.RSSI = RSSI
        NotificationCenter.default.post(name: .afrCentralManagerDidDiscoverDevice, object: nil, userInfo: ["identifier": peripheral.identifier])
        debugPrint("[Central] afrCentralManagerDidDiscoverPeripheral: \(peripheral.identifier.uuidString)")
    }

    /// CBCentralManagerDelegate
    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        devices[peripheral.identifier]?.reset()
        peripheral.delegate = self
        peripheral.discoverServices([AmazonFreeRTOSGattService.DeviceInfo, AmazonFreeRTOSGattService.MqttProxy, AmazonFreeRTOSGattService.NetworkConfig])
        NotificationCenter.default.post(name: .afrCentralManagerDidConnectDevice, object: nil, userInfo: ["identifier": peripheral.identifier])
        debugPrint("[\(peripheral.identifier.uuidString)] afrCentralManagerDidConnectPeripheral")
    }

    /// CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        devices[peripheral.identifier]?.reset()
        if devices[peripheral.identifier]?.reconnect ?? false {
            central.connect(peripheral, options: nil)
        }
        NotificationCenter.default.post(name: .afrCentralManagerDidDisconnectDevice, object: nil, userInfo: ["identifier": peripheral.identifier])
        if let error = error {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrCentralManagerDidDisconnectPeripheral: \(error.localizedDescription)")
            return
        }
        debugPrint("[\(peripheral.identifier.uuidString)] afrCentralManagerDidDisconnectPeripheral")
    }

    /// CBCentralManagerDelegate
    public func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NotificationCenter.default.post(name: .afrCentralManagerDidFailToConnectDevice, object: nil, userInfo: ["identifier": peripheral.identifier])
        if let error = error {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrCentralManagerDidFailToConnectPeripheral: \(error.localizedDescription)")
            return
        }
        debugPrint("[\(peripheral.identifier.uuidString)] afrCentralManagerDidFailToConnectPeripheral")
    }
}

extension AmazonFreeRTOSManager: CBPeripheralDelegate {

    /// CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrPeripheralDidDiscoverServices: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        NotificationCenter.default.post(name: .afrPeripheralDidDiscoverServices, object: nil, userInfo: ["peripheral": peripheral])
    }

    /// CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrPeripheralDidDiscoverCharacteristics: \(error.localizedDescription)")
            return
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }
        switch service.uuid {

        case AmazonFreeRTOSGattService.DeviceInfo:
            devices[peripheral.identifier]?.getAfrVersion()
            devices[peripheral.identifier]?.getBrokerEndpoint()
            devices[peripheral.identifier]?.getMtu()
            devices[peripheral.identifier]?.getAfrPlatform()
            devices[peripheral.identifier]?.getAfrDevId()

        case AmazonFreeRTOSGattService.MqttProxy:
            guard let characteristic = service.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.MqttProxyControl) else {
                debugPrint("[\(peripheral.identifier.uuidString)][ERROR] MqttServiceState characteristic doesn't exist")
                return
            }
            devices[peripheral.identifier]?.peripheral.writeValue(Data([1]), for: characteristic, type: .withResponse)

        case AmazonFreeRTOSGattService.NetworkConfig:
            guard let characteristic = service.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.NetworkConfigControl) else {
                debugPrint("[\(peripheral.identifier.uuidString)][ERROR] NetworkServiceState characteristic doesn't exist")
                return
            }
            devices[peripheral.identifier]?.peripheral.writeValue(Data([1]), for: characteristic, type: .withResponse)

        default:
            return
        }

        NotificationCenter.default.post(name: .afrPeripheralDidDiscoverCharacteristics, object: nil, userInfo: ["peripheral": peripheral, "service": service])
    }

    /// CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if let error = error {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrPeripheralDidUpdateValueForCharacteristic: \(error.localizedDescription)")
            return
        }

        switch characteristic.uuid {

        case AmazonFreeRTOSGattCharacteristic.AfrVersion:
            didUpdateValueForAfrVersion(peripheral: peripheral, characteristic: characteristic)

        case AmazonFreeRTOSGattCharacteristic.BrokerEndpoint:
            didUpdateValueForBrokerEndpoint(peripheral: peripheral, characteristic: characteristic)

        case AmazonFreeRTOSGattCharacteristic.Mtu:
            didUpdateValueForMtu(peripheral: peripheral, characteristic: characteristic)

        case AmazonFreeRTOSGattCharacteristic.AfrPlatform:
            didUpdateValueForAfrPlatform(peripheral: peripheral, characteristic: characteristic)

        case AmazonFreeRTOSGattCharacteristic.AfrDevId:
            didUpdateValueForAfrDevId(peripheral: peripheral, characteristic: characteristic)

        case AmazonFreeRTOSGattCharacteristic.TXMqttMessage, AmazonFreeRTOSGattCharacteristic.TXNetworkMessage:
            didUpdateValueForTXMessage(peripheral: peripheral, characteristic: characteristic, data: nil)

        case AmazonFreeRTOSGattCharacteristic.TXLargeMqttMessage, AmazonFreeRTOSGattCharacteristic.TXLargeNetworkMessage:
            didUpdateValueForTXLargeMessage(peripheral: peripheral, characteristic: characteristic)

        default:
            return
        }
    }

    /// CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

        if let error = error {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrPeripheralDidWriteValueForCharacteristic: \(error.localizedDescription)")
            return
        }

        switch characteristic.uuid {

        case AmazonFreeRTOSGattCharacteristic.RXLargeMqttMessage, AmazonFreeRTOSGattCharacteristic.RXLargeNetworkMessage:
            writeValueToRXLargeMessage(peripheral: peripheral, characteristic: characteristic)

        default:
            return
        }
    }
}

extension AmazonFreeRTOSManager {

    internal func encode<T: Encodable>(_ object: T) -> Data? {
        do {
            let encoder = CBOREncoder()
            let encoded = try encoder.encode(object)
            return Data(encoded)
        } catch {
            debugPrint("[ERROR] CBOR decode error: \(error)")
        }
        return nil
    }

    internal func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            let decoder = CBORDecoder()
            let decoded = try decoder.decode(type, from: data)
            return decoded
        } catch {
            debugPrint("[ERROR] CBOR decode error: \(error)")
        }
        return nil
    }

    internal func debugPrint(_ debugMessage: String) {
        guard isDebug else {
            return
        }
        debugMessages += "\(Date())-\(debugMessage)\n"
        os_log("[AFR]%@", log: .default, type: .debug, debugMessage)
    }
}

extension AmazonFreeRTOSManager {

    /// Process data of AfrVersion characteristic from `peripheral`.
    ///
    /// - Parameters:
    ///    - peripheral: The FreeRTOS peripheral.
    ///    - characteristic: The AfrVersion characteristic.
    public func didUpdateValueForAfrVersion(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let afrVersion = String(data: value, encoding: .utf8) else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrDeviceInfoAfrVersion: Invalid AfrVersion")
            return
        }
        devices[peripheral.identifier]?.afrVersion = afrVersion
        devices[peripheral.identifier]?.updateIoTDataManager()
        NotificationCenter.default.post(name: .afrDeviceInfoAfrVersion, object: nil, userInfo: ["afrVersion": afrVersion])
        debugPrint("[\(peripheral.identifier.uuidString)] → afrDeviceInfoAfrVersion: \(afrVersion)")
    }

    /// Process data of BrokerEndpoint characteristic from `peripheral`.
    ///
    /// - Parameters:
    ///     - peripheral: The FreeRTOS peripheral.
    ///     - characteristic: The BrokerEndpoint characteristic.
    ///
    public func didUpdateValueForBrokerEndpoint(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let brokerEndpoint = String(data: value, encoding: .utf8) else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrDeviceInfoBrokerEndpoint: Invalid BrokerEndpoint")
            return
        }
        devices[peripheral.identifier]?.brokerEndpoint = brokerEndpoint
        NotificationCenter.default.post(name: .afrDeviceInfoBrokerEndpoint, object: nil, userInfo: ["brokerEndpoint": brokerEndpoint])
        debugPrint("[\(peripheral.identifier.uuidString)] → afrDeviceInfoBrokerEndpoint: \(brokerEndpoint)")
    }

    /// Process data of Mtu characteristic from `peripheral`. It will also triger on mtu value change.
    ///
    /// - Parameters:
    ///     - peripheral: The FreeRTOS peripheral.
    ///     - characteristic: The Mtu characteristic.
    public func didUpdateValueForMtu(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let mtuStr = String(data: value, encoding: .utf8), let mtu = Int(mtuStr), mtu > 3 else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrDeviceInfoMtu: Invalid Mtu")
            return
        }
        devices[peripheral.identifier]?.mtu = mtu
        NotificationCenter.default.post(name: .afrDeviceInfoMtu, object: nil, userInfo: ["mtu": mtu])
        debugPrint("[\(peripheral.identifier.uuidString)] → afrDeviceInfoMtu: \(mtu)")
    }

    /// Process data of AfrPlatform characteristic from `peripheral`.
    ///
    /// - Parameters:
    ///     - peripheral: The FreeRTOS peripheral.
    ///     - characteristic: The AfrPlatform characteristic.
    public func didUpdateValueForAfrPlatform(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let afrPlatform = String(data: value, encoding: .utf8) else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrDeviceInfoAfrPlatform: Invalid AfrPlatform")
            return
        }
        devices[peripheral.identifier]?.afrPlatform = afrPlatform
        devices[peripheral.identifier]?.updateIoTDataManager()
        NotificationCenter.default.post(name: .afrDeviceInfoAfrPlatform, object: nil, userInfo: ["afrPlatform": afrPlatform])
        debugPrint("[\(peripheral.identifier.uuidString)] → afrDeviceInfoAfrPlatform: \(afrPlatform)")
    }

    /// Process data of AfrDevId characteristic from `peripheral`.
    ///
    /// - Parameters:
    ///     - peripheral: The FreeRTOS peripheral.
    ///     - characteristic: The AfrDevId characteristic.
    public func didUpdateValueForAfrDevId(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let afrDevId = String(data: value, encoding: .utf8) else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] afrDeviceInfoAfrDevId: Invalid AfrDevId")
            return
        }
        devices[peripheral.identifier]?.afrDevId = afrDevId
        devices[peripheral.identifier]?.updateIoTDataManager()
        NotificationCenter.default.post(name: .afrDeviceInfoAfrDevId, object: nil, userInfo: ["afrDevId": afrDevId])
        debugPrint("[\(peripheral.identifier.uuidString)] → afrDeviceInfoAfrDevId: \(afrDevId)")
    }
}

extension AmazonFreeRTOSManager {

    // Process data of TXMqttMessage or TXNetworkMessage characteristic from `peripheral`.
    internal func didUpdateValueForTXMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data?) {

        guard let value = data ?? characteristic.value else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] didUpdateValueForTXMessage: Invalid message")
            return
        }

        let testCharacteristicService: CBService? = characteristic.service
        guard let guardCharacteristicService = testCharacteristicService else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] didUpdateValueForTXMessage: Invalid characteristic")
            return
        }
        let characteristicService: CBService = guardCharacteristicService

        switch characteristicService.uuid {

        case AmazonFreeRTOSGattService.MqttProxy:

            guard let mqttMessage = decode(MqttMessage.self, from: value) else {
                debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid message")
                return
            }

            switch mqttMessage.type {

            case .connect:

                guard let connect = decode(Connect.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid connect")
                    return
                }

                debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↑ \(connect)")

                if !(devices[peripheral.identifier]?.registerIoTDataManager(connect: connect) ?? false) {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid connect: registerIoTDataManager failed")
                    return
                }

                if let certificateId = devices[peripheral.identifier]?.certificateId {
                    AWSIoTDataManager(forKey: peripheral.identifier.uuidString).connect(withClientId: connect.clientID, cleanSession: connect.cleanSession, certificateId: certificateId) { status in

                        switch status {

                        case .connected:
                            self.mqttConnack(peripheral: peripheral, characteristic: characteristic, status: status.rawValue)

                        default:
                            self.debugPrint("[\(peripheral.identifier.uuidString)][MQTT] connectUsingWebSocket status: \(status.rawValue)")
                            return
                        }
                    }
                } else if devices[peripheral.identifier]?.credentialsProvider != nil {
                    AWSIoTDataManager(forKey: peripheral.identifier.uuidString).connectUsingWebSocket(withClientId: connect.clientID, cleanSession: connect.cleanSession) { status in

                        switch status {

                        case .connected:
                            self.mqttConnack(peripheral: peripheral, characteristic: characteristic, status: status.rawValue)

                        default:
                            self.debugPrint("[\(peripheral.identifier.uuidString)][MQTT] connectUsingWebSocket status: \(status.rawValue)")
                            return
                        }
                    }
                } else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid connect: No credential")
                }

            case .publish:

                guard let publish = decode(Publish.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid publish")
                    return
                }

                debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↑ \(publish)")

                guard let qoS = AWSIoTMQTTQoS(rawValue: publish.qoS) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid publish: qoS")
                    return
                }

                if qoS == AWSIoTMQTTQoS.messageDeliveryAttemptedAtMostOnce {
                    AWSIoTDataManager(forKey: peripheral.identifier.uuidString).publishData(publish.payload, onTopic: publish.topic, qoS: qoS)
                    return
                }
                AWSIoTDataManager(forKey: peripheral.identifier.uuidString).publishData(publish.payload, onTopic: publish.topic, qoS: qoS) {
                    self.mqttPuback(peripheral: peripheral, characteristic: characteristic, msgID: publish.msgID)
                }

            case .puback:
                // need aws iot sdk change, current it auto send puback when recived at sdk side.
                return

            case .subscribe:

                guard let subscribe = decode(Subscribe.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid subscribe")
                    return
                }

                debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↑ \(subscribe)")

                guard subscribe.topics.count == subscribe.qoSs.count else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid subscribe: topics and qoSs not match")
                    return
                }

                for (index, topic) in subscribe.topics.enumerated() {

                    guard let qoS = AWSIoTMQTTQoS(rawValue: subscribe.qoSs[index]) else {
                        debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid subscribe: qoS")
                        return
                    }

                    AWSIoTDataManager(forKey: peripheral.identifier.uuidString).subscribe(toTopic: topic, qoS: qoS, messageCallback: { data in
                        self.mqttPublish(peripheral: peripheral, characteristic: characteristic, msgID: subscribe.msgID, topic: topic, qoS: subscribe.qoSs[index], data: data)
                    }, ackCallback: {
                        self.mqttSuback(peripheral: peripheral, characteristic: characteristic, msgID: subscribe.msgID, status: subscribe.qoSs[index])
                    })
                }

            case .unsubscribe:

                guard let unsubscribe = decode(Unsubscribe.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid unsubscribe")
                    return
                }

                debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↑ \(unsubscribe)")

                for topic in unsubscribe.topics {

                    AWSIoTDataManager(forKey: peripheral.identifier.uuidString).unsubscribeTopic(topic)

                    mqttUnsubscribe(peripheral: peripheral, characteristic: characteristic, msgID: unsubscribe.msgID)
                }

            case .disconnnect:

                guard let disconnect = decode(Disconnect.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid disconnect")
                    return
                }

                debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↑ \(disconnect)")

                devices[peripheral.identifier]?.removeIoTDataManager()

            case .pingreq:

                guard let pingreq = decode(Pingreq.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid pingreq")
                    return
                }

                debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↑ \(pingreq)")

                guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                    return
                }

                mqttPingresp(peripheral: peripheral, characteristic: characteristic)

            default:
                return
            }

        case AmazonFreeRTOSGattService.NetworkConfig:

            guard let networkMessage = decode(NetworkMessage.self, from: value) else {
                debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid message")
                return
            }

            switch networkMessage.type {

            case .listNetworkResp:
                guard let listNetworkResp = decode(ListNetworkResp.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid listNetworkResp")
                    return
                }
                debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] → \(listNetworkResp)")

                if listNetworkResp.index < 0 {

                    // Scaned networks also include saved networks so we filter that out when ssid and security are the same, update the saved network with the scaned bssid, rssi and hidden prams.

                    if let indexSaved = devices[peripheral.identifier]?.savedNetworks.firstIndex(where: { network -> Bool in
                        network.ssid == listNetworkResp.ssid && network.security == listNetworkResp.security
                    }) {
                        if let rssi = devices[peripheral.identifier]?.savedNetworks[indexSaved].rssi, rssi < listNetworkResp.rssi {
                            devices[peripheral.identifier]?.savedNetworks[indexSaved].status = listNetworkResp.status
                            devices[peripheral.identifier]?.savedNetworks[indexSaved].bssid = listNetworkResp.bssid
                            devices[peripheral.identifier]?.savedNetworks[indexSaved].rssi = listNetworkResp.rssi
                            devices[peripheral.identifier]?.savedNetworks[indexSaved].hidden = listNetworkResp.hidden
                        }
                        return
                    }

                    // Scaned networks sorted by rssi, if ssid and security are same, choose the network with stronger rssi.

                    if let indexScaned = devices[peripheral.identifier]?.scanedNetworks.firstIndex(where: { network -> Bool in
                        network.ssid == listNetworkResp.ssid && network.security == listNetworkResp.security
                    }) {
                        if let rssi = devices[peripheral.identifier]?.scanedNetworks[indexScaned].rssi, rssi < listNetworkResp.rssi {
                            devices[peripheral.identifier]?.scanedNetworks[indexScaned] = listNetworkResp
                        }
                    } else {
                        devices[peripheral.identifier]?.scanedNetworks.append(listNetworkResp)
                    }
                    devices[peripheral.identifier]?.scanedNetworks.sort(by: { networkA, networkB -> Bool in
                        networkA.rssi > networkB.rssi
                    })
                } else {

                    // Saved networks sorted by index

                    devices[peripheral.identifier]?.savedNetworks.append(listNetworkResp)
                    devices[peripheral.identifier]?.savedNetworks.sort(by: { networkA, networkB -> Bool in
                        networkA.index < networkB.index
                    })
                }
                NotificationCenter.default.post(name: .afrDidListNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "listNetworkResp": listNetworkResp])

            case .saveNetworkResp:
                guard let saveNetworkResp = decode(SaveNetworkResp.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid saveNetworkResp")
                    return
                }
                debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] → \(saveNetworkResp)")
                NotificationCenter.default.post(name: .afrDidSaveNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "saveNetworkResp": saveNetworkResp])

            case .editNetworkResp:
                guard let editNetworkResp = decode(EditNetworkResp.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid editNetworkResp")
                    return
                }
                debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] → \(editNetworkResp)")
                NotificationCenter.default.post(name: .afrDidEditNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "editNetworkResp": editNetworkResp])

            case .deleteNetworkResp:
                guard let deleteNetworkResp = decode(DeleteNetworkResp.self, from: value) else {
                    debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid deleteNetworkResp")
                    return
                }
                debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] → \(deleteNetworkResp)")
                NotificationCenter.default.post(name: .afrDidDeleteNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "deleteNetworkResp": deleteNetworkResp])

            default:
                return
            }

        default:
            return
        }
    }

    // Process data of TXLargeMqttMessage or TXLargeNetworkMessage characteristic from `peripheral`. Used by large object transfer.
    internal func didUpdateValueForTXLargeMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let mtu = devices[peripheral.identifier]?.mtu else {
            debugPrint("[\(peripheral.identifier.uuidString)][LOT][ERROR] Mtu unknown")
            return
        }

        let testCharacteristicService: CBService? = characteristic.service
        guard let guardCharacteristicService = testCharacteristicService else {
            debugPrint("[\(peripheral.identifier.uuidString)][ERROR] didUpdateValueForTXLargeMessage: Invalid characteristic")
            return
        }
        let characteristicService: CBService = guardCharacteristicService

        if let txLotData = devices[peripheral.identifier]?.txLotDatas[characteristicService.uuid.uuidString], let value = characteristic.value {
            let data = Data([UInt8](txLotData) + [UInt8](value))
            devices[peripheral.identifier]?.txLotDatas[characteristicService.uuid.uuidString] = data
            debugPrint("[\(peripheral.identifier.uuidString)][LOT] ↑ \(data)")
        } else if let value = characteristic.value {
            devices[peripheral.identifier]?.txLotDatas[characteristicService.uuid.uuidString] = value
            debugPrint("[\(peripheral.identifier.uuidString)][LOT] ↑ \(value)")
        }
        if characteristic.value?.count ?? 0 < mtu - 3 {
            if let txLotData = devices[peripheral.identifier]?.txLotDatas[characteristicService.uuid.uuidString] {
                didUpdateValueForTXMessage(peripheral: peripheral, characteristic: characteristic, data: txLotData)
                debugPrint("[\(peripheral.identifier.uuidString)][LOT] LAST FULL ↑ \(txLotData)")
            }
            devices[peripheral.identifier]?.txLotDatas.removeValue(forKey: characteristicService.uuid.uuidString)
        } else {
            peripheral.readValue(for: characteristic)
        }
    }

    // Write data to RXMqttMessage or RXNetworkMessage characteristic of `peripheral`. Used by large object transfer.
    internal func writeValueToRXMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data) {
        DispatchQueue.main.async {
            guard let mtu = self.devices[peripheral.identifier]?.mtu else {
                self.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] Mtu unknown")
                return
            }

            let testCharacteristicService: CBService? = characteristic.service
            guard let guardCharacteristicService = testCharacteristicService else {
                self.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] writeValueToRXMessage: Invalid characteristic")
                return
            }
            let characteristicService: CBService = guardCharacteristicService

            if data.count > mtu - 3 {
                guard let characteristic = characteristicService.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXLargeMqttMessage) ?? characteristicService.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXLargeNetworkMessage) else {
                    self.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] RXLargeMqttMessage or RXLargeNetworkMessage characteristic doesn't exist")
                    return
                }
                if self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString] == nil {
                    self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString] = [data]
                } else {
                    self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?.append(data)
                }
                if self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?.count == 1 {
                    self.writeValueToRXLargeMessage(peripheral: peripheral, characteristic: characteristic)
                }
                return
            }
            guard let characteristic = characteristicService.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXMqttMessage) ?? characteristicService.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXNetworkMessage) else {
                self.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] RXMqttMessage or RXNetworkMessage characteristic doesn't exist")
                return
            }

            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }

    // Write data to RXLargeMqttMessage or RXLargeNetworkMessage characteristic of `peripheral`. Used by large object transfer.
    internal func writeValueToRXLargeMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        DispatchQueue.main.async {
            guard let mtu = self.devices[peripheral.identifier]?.mtu else {
                self.debugPrint("[\(peripheral.identifier.uuidString)][LOT][ERROR] Mtu unknown")
                return
            }

            let testCharacteristicService: CBService? = characteristic.service
            guard let guardCharacteristicService = testCharacteristicService else {
                self.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] writeValueToRXLargeMessage: Invalid characteristic")
                return
            }
            let characteristicService: CBService = guardCharacteristicService

            guard let rxLotData = self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?.first else {
                return
            }
            let data = Data([UInt8](rxLotData).prefix(mtu - 3))
            if data.count < mtu - 3 {
                self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?.removeFirst()
                self.debugPrint("[\(peripheral.identifier.uuidString)][LOT] LAST PART ↓ \(data) - \(self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?.count ?? 0) in queue")
            } else {
                self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?[0] = Data([UInt8](rxLotData).dropFirst(mtu - 3))
                self.debugPrint("[\(peripheral.identifier.uuidString)][LOT] ↓ \(rxLotData) - \(self.devices[peripheral.identifier]?.rxLotDataQueues[characteristicService.uuid.uuidString]?.count ?? 0) in queue")
            }
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension AmazonFreeRTOSManager {

    internal func mqttConnack(peripheral: CBPeripheral, characteristic: CBCharacteristic, status: Int) {

        let connack = Connack(status: status)

        debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↓ \(connack)")

        guard let data = encode(connack) else {
            debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid connack")
            return
        }

        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func mqttPuback(peripheral: CBPeripheral, characteristic: CBCharacteristic, msgID: Int) {

        let puback = Puback(msgID: msgID)

        debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↓ \(puback)")

        guard let data = encode(puback) else {
            debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid puback")
            return
        }

        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func mqttPublish(peripheral: CBPeripheral, characteristic: CBCharacteristic, msgID: Int, topic: String, qoS: Int, data: Data) {

        let publish = Publish(topic: topic, msgID: msgID, qoS: qoS, payload: data)

        debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↓ \(publish)")

        guard let data = encode(publish) else {
            debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid publish")
            return
        }

        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func mqttSuback(peripheral: CBPeripheral, characteristic: CBCharacteristic, msgID: Int, status: Int) {

        let suback = Suback(msgID: msgID, status: status)

        debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↓ \(suback)")

        guard let data = encode(suback) else {
            debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid suback")
            return
        }

        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func mqttUnsubscribe(peripheral: CBPeripheral, characteristic: CBCharacteristic, msgID: Int) {

        let unsuback = Unsuback(msgID: msgID)

        debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↓ \(unsuback)")

        guard let data = encode(unsuback) else {
            debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid unsuback")
            return
        }

        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func mqttPingresp(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        let pingresp = Pingresp()

        debugPrint("[\(peripheral.identifier.uuidString)][MQTT] ↓ \(pingresp)")

        guard let data = encode(pingresp) else {
            debugPrint("[\(peripheral.identifier.uuidString)][MQTT][ERROR] Invalid pingresp")
            return
        }

        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }
}

extension AmazonFreeRTOSManager {

    internal func listNetwork(_ peripheral: CBPeripheral, listNetworkReq: ListNetworkReq) {

        debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] ↓ \(listNetworkReq)")

        guard let data = encode(listNetworkReq) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid listNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.NetworkConfig)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXNetworkMessage) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] NetworkConfig service or RXNetworkMessage characteristic doesn't exist")
            return
        }
        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func saveNetwork(_ peripheral: CBPeripheral, saveNetworkReq: SaveNetworkReq) {

        debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] ↓ \(saveNetworkReq)")

        guard let data = encode(saveNetworkReq) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid saveNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.NetworkConfig)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXNetworkMessage) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] NetworkConfig service or RXNetworkMessage characteristic doesn't exist")
            return
        }
        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func editNetwork(_ peripheral: CBPeripheral, editNetworkReq: EditNetworkReq) {

        debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] ↓ \(editNetworkReq)")

        guard let data = encode(editNetworkReq) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid editNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.NetworkConfig)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXNetworkMessage) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] NetworkConfig service or RXNetworkMessage characteristic doesn't exist")
            return
        }
        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    internal func deleteNetwork(_ peripheral: CBPeripheral, deleteNetworkReq: DeleteNetworkReq) {

        debugPrint("[\(peripheral.identifier.uuidString)][NETWORK] ↓ \(deleteNetworkReq)")

        guard let data = encode(deleteNetworkReq) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] Invalid deleteNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.NetworkConfig)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.RXNetworkMessage) else {
            debugPrint("[\(peripheral.identifier.uuidString)][NETWORK][ERROR] NetworkConfig service or RXNetworkMessage characteristic doesn't exist")
            return
        }
        writeValueToRXMessage(peripheral: peripheral, characteristic: characteristic, data: data)
    }
}
