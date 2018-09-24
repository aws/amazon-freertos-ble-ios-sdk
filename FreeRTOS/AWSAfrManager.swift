import AWSCore
import AWSIoT
import AWSMobileClient
import CoreBluetooth
import Foundation
import os.log

class AWSAfrManager: NSObject {

    /// Shared instence of Amazon FreeRTOS Manager.
    static let shared = AWSAfrManager()

    #warning("delete")

    var isDebug: Bool = false
    var debugMessages = String()
    var counter = 0

    #warning("delete")

    // BLE Central Manager for the SDK
    private var central: CBCentralManager?

    /// The peripherals using peripheral identifier as key.
    var peripherals: [String: CBPeripheral] = [:]
    /// The topics mapping for peripherals using peripheral identifier as key.
    var topics: [String: [Int: Topic]] = [:]
    /// The networks peripherals scaned using peripheral identifier as key.
    var networks: [String: [[ListNetworkResp]]] = [:]
    /// The mtus for peripherals using peripheral identifier as key.
    var mtus: [String: Mtu] = [:]
    /// The broker endpoints for peripherals using peripheral identifier as key.
    var brokerEndpoints: [String: BrokerEndpoint] = [:]
    /// The timeouts for peripherals using peripheral identifier as key.
    var timeouts: [String: Timeout] = [:]

    // used for large object transfer with peripheral identifier and characteristic uuid as keys.
    private var lotDatas: [String: Data] = [:]

    /**
     Initializes a new Amazon FreeRTOS Manager.

     - Returns: A new Amazon FreeRTOS Manager.
     */
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

// This section are the methods for when using the build-in BLE central. It includes the BLE Helpers to scan and connect to the peripheral, methods to start the Mqtt Proxy Service and methods to operate the Network Config Service.
extension AWSAfrManager {

    // BLE Helper

    /// Start scan for FreeRTOS peripherals.
    func startScanForPeripherals() {
        if let central = central, !central.isScanning {
            central.scanForPeripherals(withServices: [AWSAfrGattService.FreeRTOS], options: nil)
        }
    }

    /// Stop scan for FreeRTOS peripherals.
    func stopScanForPeripherals() {
        if let central = central, central.isScanning {
            central.stopScan()
        }
    }

    /// Rescan for FreeRTOS peripherals and clear all contexts.
    func rescanForPeripherals() {
        stopScanForPeripherals()

        peripherals.removeAll()
        topics.removeAll()
        networks.removeAll()

        mtus.removeAll()
        brokerEndpoints.removeAll()
        timeouts.removeAll()

        lotDatas.removeAll()
        startScanForPeripherals()
    }

    /**
     Connect to FreeRTOS `peripheral`

     - Parameter peripheral: the FreeRTOS peripheral.
     - Precondition: `central` is NOT Nil and `peripheral` must be disconnected.
     */
    func connectPeripheral(_ peripheral: CBPeripheral) {
        if let central = central, peripheral.state == .disconnected {
            central.connect(peripheral, options: nil)
        }
    }

    /**
     Disconnect from FreeRTOS `peripheral`

     - Parameter peripheral: the FreeRTOS peripheral.
     - Precondition: `central` is NOT Nil and `peripheral` must NOT be disconnected.
     */
    func disconnectPeripheral(_ peripheral: CBPeripheral) {
        if let central = central, peripheral.state != .disconnected {
            for service in peripheral.services ?? [] {
                for characteristic in service.characteristics ?? [] {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
            central.cancelPeripheralConnection(peripheral)
        }
    }

    // Mqtt Proxy Service

    /**
     Disconnect from FreeRTOS `peripheral`

     - Parameter peripheral: the FreeRTOS peripheral.
     - Precondition: the Mqtt Service has been discovered.
     */
    func startMqttOfPeripheral(_ peripheral: CBPeripheral) {
        guard let service = peripheral.serviceOf(uuid: AWSAfrGattService.Mqtt) else {
            debugPrint("Error (startMqttOfPeripheral): Mqtt service doesn't exist")
            return
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    // Network Config Service

    /**
     Disconnect from FreeRTOS `peripheral`

     - Parameter peripheral: the FreeRTOS peripheral.
     - Precondition: the Network Service has been discovered.
     */
    func startNetworkOfPeripheral(_ peripheral: CBPeripheral) {
        guard let service = peripheral.serviceOf(uuid: AWSAfrGattService.Network) else {
            debugPrint("Error (startNetworkOfPeripheral): Network service doesn't exist")
            return
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    /**
     List saved and scanned wifi networks of `peripheral`. Wifi networks are returned one by one, saved wifi ordered by priority and scanned wifi ordered by signal strength (rssi)

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - listNetworkReq: The List Network Request
     */
    func listNetworkOfPeripheral(_ peripheral: CBPeripheral, listNetworkReq: ListNetworkReq) {

        debugPrint("↓ \(listNetworkReq)")

        networks[peripheral.identifier.uuidString] = [[], []]

        guard let data = try? JSONEncoder().encode(listNetworkReq) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid ListNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.Network)?.characteristicOf(uuid: AWSAfrGattCharacteristic.ListNetwork) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid ListNetworkReq - Network service or ListNetwork characteristic doesn't exist ")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    /**
     Save wifi network to `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - saveNetworkReq: The Save Network Request
     */
    func saveNetworkToPeripheral(_ peripheral: CBPeripheral, saveNetworkReq: SaveNetworkReq) {

        debugPrint("↓ \(saveNetworkReq)")

        guard let data = try? JSONEncoder().encode(saveNetworkReq) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid SaveNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.Network)?.characteristicOf(uuid: AWSAfrGattCharacteristic.SaveNetwork) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid SaveNetworkReq - service or characteristic doesn't exist ")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    /**
     Edit wifi network of `peripheral`. Currently only support priority change

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - editNetworkReq: The Edit Network Request
     */
    func editNetworkOfPeripheral(_ peripheral: CBPeripheral, editNetworkReq: EditNetworkReq) {

        debugPrint("↓ \(editNetworkReq)")

        guard let data = try? JSONEncoder().encode(editNetworkReq) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid EditNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.Network)?.characteristicOf(uuid: AWSAfrGattCharacteristic.EditNetwork) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid EditNetworkReq - service or characteristic doesn't exist ")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    /**
     Delete saved wifi network from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - deleteNetworkReq: The Delete Network Request
     */
    func deleteNetworkFromPeripheral(_ peripheral: CBPeripheral, deleteNetworkReq: DeleteNetworkReq) {

        debugPrint("↓ \(deleteNetworkReq)")

        guard let data = try? JSONEncoder().encode(deleteNetworkReq) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid DeleteNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.Network)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DeleteNetwork) else {
            debugPrint("Error (writeValueForCharacteristic): Invalid DeleteNetworkReq - service or characteristic doesn't exist ")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// This section are the methods for CBCentralManagerDelegate. It should not be used directly.
extension AWSAfrManager: CBCentralManagerDelegate {

    // BLE state change
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanForPeripherals()
            return
        }
        stopScanForPeripherals()
    }

    // Scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        debugPrint("→ \(advertisementData)")
        if peripherals.keys.contains(peripheral.identifier.uuidString) {
            return
        }
        peripherals[peripheral.identifier.uuidString] = peripheral
        NotificationCenter.default.post(name: .didDiscoverPeripheral, object: nil)
    }

    // Connection
    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        topics[peripheral.identifier.uuidString] = [:]
        networks[peripheral.identifier.uuidString] = [[], []]

        #warning("delete")

        topics[peripheral.identifier.uuidString] = [1: Topic(type: .topic, topicID: 1, topicValue: "freertos/demos/echo")]

        #warning("delete")

        peripheral.delegate = self
        peripheral.discoverServices([AWSAfrGattService.Mqtt, AWSAfrGattService.Network])
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            debugPrint("Error (didDisconnectPeripheral): \(error.localizedDescription)")
        }
        topics.removeValue(forKey: peripheral.identifier.uuidString)
        networks.removeValue(forKey: peripheral.identifier.uuidString)
        AWSIoTDataManager(forKey: peripheral.identifier.uuidString).disconnect()
    }

    func centralManager(_: CBCentralManager, didFailToConnect _: CBPeripheral, error: Error?) {
        if let error = error {
            debugPrint("Error (didFailToConnect): \(error.localizedDescription)")
        }
    }
}

extension AWSAfrManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            debugPrint("Error (didDiscoverServices): \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        NotificationCenter.default.post(name: .didDiscoverServices, object: nil, userInfo: ["peripheral": peripheral.identifier])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            debugPrint("Error (didDiscoverCharacteristicsFor): \(error.localizedDescription)")
            return
        }
        NotificationCenter.default.post(name: .didDiscoverCharacteristics, object: nil, userInfo: ["peripheral": peripheral.identifier, "service": service.uuid])
    }

    // read, write

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugPrint("Error (didUpdateValueFor): \(error.localizedDescription)")
            return
        }

        switch characteristic.uuid {

        case AWSAfrGattCharacteristic.Metadata:
            didUpdateValueForMetadata(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.TXMessage:
            didUpdateValueForTXMessage(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.TXLargeMessage:
            didUpdateValueForTXLargeMessage(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.ListNetwork:
            didUpdateValueForListNetwork(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.SaveNetwork:
            didUpdateValueForSaveNetwork(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.EditNetwork:
            didUpdateValueForEditNetwork(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.DeleteNetwork:
            didUpdateValueForDeleteNetwork(peripheral: peripheral, characteristic: characteristic)

        default:
            debugPrint("Error (didUpdateValueFor): Unsupported Characteristic")
            return
        }
    }

    func peripheral(_: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugPrint("Error (didWriteValueFor): \(error.localizedDescription)")
            return
        }
        if let value = characteristic.value {
            debugPrint("Value (didWriteValueForCharacteristic): \(String(data: value, encoding: .utf8) ?? String())")
        }
    }
}

extension AWSAfrManager {

    func didUpdateValueForMetadata(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let metadataMessage = try? JSONDecoder().decode(MetadataMessage.self, from: value) else {
            debugPrint("Error (didUpdateValueForTXMessage): Invalid Metadata Message")
            return
        }

        switch metadataMessage.type {

        case .topic:
            guard let topic = try? JSONDecoder().decode(Topic.self, from: value) else {
                debugPrint("Error (didUpdateValueForMetadata): Invalid Topic")
                return
            }
            debugPrint("→ \(topic)")
            topics[peripheral.identifier.uuidString] = [topic.topicID: topic]

        case .mtu:
            guard let mtu = try? JSONDecoder().decode(Mtu.self, from: value) else {
                debugPrint("Error (didUpdateValueForMetadata): Invalid Mtu")
                return
            }
            debugPrint("→ \(mtu)")
            mtus[peripheral.identifier.uuidString] = mtu

        case .brokerEndpoint:
            guard let brokerEndpoint = try? JSONDecoder().decode(BrokerEndpoint.self, from: value) else {
                debugPrint("Error (didUpdateValueForMetadata): Invalid BrokerEndpoint")
                return
            }
            debugPrint("→ \(brokerEndpoint)")
            brokerEndpoints[peripheral.identifier.uuidString] = brokerEndpoint

        case .timeout:
            guard let timeout = try? JSONDecoder().decode(Timeout.self, from: value) else {
                debugPrint("Error (didUpdateValueForMetadata): Invalid Timeout")
                return
            }
            debugPrint("→ \(timeout)")
            timeouts[peripheral.identifier.uuidString] = timeout
        }
    }

    func didUpdateValueForTXMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let mqttMessage = try? JSONDecoder().decode(MqttMessage.self, from: value) else {
            debugPrint("Error (didUpdateValueForTXMessage): Invalid Mqtt Message")
            return
        }

        switch mqttMessage.type {

        case .connect:

            guard let connect = try? JSONDecoder().decode(Connect.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect")
                return
            }

            debugPrint("↑ \(connect)")

            guard let region = connect.brokerEndpoint.split(separator: ".").object(at: 2) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect - region ")
                return
            }

            guard let serviceConfiguration = AWSServiceConfiguration(region: String(region).aws_regionTypeValue(), endpoint: AWSEndpoint(urlString: "https://\(connect.brokerEndpoint)"), credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider()) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect - serviceConfiguration ")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() != .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect - already connected ")
                return
            }

            AWSIoTDataManager.register(with: serviceConfiguration, forKey: peripheral.identifier.uuidString)
            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).connectUsingWebSocket(withClientId: connect.clientID, cleanSession: connect.cleanSession) { status in

                switch status {

                case .connected:

                    guard peripheral.state == .connected else {
                        return
                    }

                    let connack = Connack(type: .connack, status: status.rawValue)
                    self.debugPrint("↓ \(connack)")

                    guard let data = try? JSONEncoder().encode(connack) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Connack")
                        return
                    }
                    DispatchQueue.main.async {
                        guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                            self.debugPrint("Error (writeValueForCharacteristic): Invalid Connack - characteristic doesn't exist ")
                            return
                        }
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    }

                default:
                    return
                }
            }

        case .publish:

            guard let publish = try? JSONDecoder().decode(Publish.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish")
                return
            }

            debugPrint("↑ \(publish)")

            guard let topic = topics[peripheral.identifier.uuidString]?[publish.topicID] else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - topic")
                return
            }

            guard let qoS = AWSIoTMQTTQoS(rawValue: publish.qoS) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - qos")
                return
            }

            switch publish.payloadType {

            case .string:

                guard let data = Data(base64Encoded: publish.payloadVal) else {
                    debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - base64")
                    return
                }

                guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                    debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - not connected ")
                    return
                }

                debugPrint("Base64 (didUpdateValueForTXMessage): \(String(data: data, encoding: .utf8) ?? String())")

                AWSIoTDataManager(forKey: peripheral.identifier.uuidString).publishData(data, onTopic: topic.topicValue, qoS: qoS) {

                    let puback = Puback(type: .puback, msgID: publish.msgID)
                    self.debugPrint("↓ \(puback)")

                    guard let data = try? JSONEncoder().encode(puback) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Puback")
                        return
                    }
                    DispatchQueue.main.async {
                        guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                            self.debugPrint("Error (writeValueForCharacteristic): Invalid Puback - characteristic doesn't exist ")
                            return
                        }
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    }
                }

            case .characteristic:
                // read
                return

            case .object:
                // read
                return
            }

        case .puback:
            // need sdk change
            return

        case .subscribe:

            guard let subscribe = try? JSONDecoder().decode(Subscribe.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe")
                return
            }

            debugPrint("↑ \(subscribe)")

            guard let topic = topics[peripheral.identifier.uuidString]?[subscribe.topicID] else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe - topic")
                return
            }

            guard let qoS = AWSIoTMQTTQoS(rawValue: subscribe.qoS) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe - qos")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe - not connected ")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).subscribe(toTopic: topic.topicValue, qoS: qoS, messageCallback: { data in

                switch subscribe.payloadType {

                case .string:

                    let publish = Publish(type: .publish, topicID: subscribe.topicID, msgID: subscribe.msgID, qoS: subscribe.qoS, payloadType: subscribe.payloadType, payloadVal: data.base64EncodedString())
                    self.debugPrint("↓ \(publish)")

                    guard let data = try? JSONEncoder().encode(publish) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Publish")
                        return
                    }
                    DispatchQueue.main.async {
                        guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                            self.debugPrint("Error (writeValueForCharacteristic): Invalid Publish - characteristic doesn't exist ")
                            return
                        }
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    }

                case .characteristic:
                    // read
                    return

                case .object:
                    // read
                    return
                }

            }, ackCallback: {

                let suback = Suback(type: .suback, msgID: subscribe.msgID, status: subscribe.qoS)
                self.debugPrint("↓ \(suback)")

                guard let data = try? JSONEncoder().encode(suback) else {
                    self.debugPrint("Error (writeValueForCharacteristic): Invalid Suback")
                    return
                }
                guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                    self.debugPrint("Error (writeValueForCharacteristic): Invalid Suback - characteristic doesn't exist ")
                    return
                }
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            })

        case .unsubscribe:

            guard let unsubscribe = try? JSONDecoder().decode(Unsubscribe.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Unsubscribe")
                return
            }

            debugPrint("↑ \(unsubscribe)")

            guard let topic = topics[peripheral.identifier.uuidString]?[unsubscribe.topicID] else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Unsubscribe - topic")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Unsubscribe - not connected ")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).unsubscribeTopic(topic.topicValue)

            let unsuback = Unsuback(type: .unsuback, msgID: unsubscribe.msgID)
            debugPrint("↓ \(unsuback)")

            guard let data = try? JSONEncoder().encode(unsuback) else {
                debugPrint("Error (writeValueForCharacteristic): Invalid Unsuback")
                return
            }
            guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                debugPrint("Error (writeValueForCharacteristic): Invalid Unsuback - characteristic doesn't exist ")
                return
            }
            peripheral.writeValue(data, for: characteristic, type: .withResponse)

        case .disconnnect:

            guard let disconnect = try? JSONDecoder().decode(Disconnect.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Disconnect")
                return
            }

            debugPrint("↑ \(disconnect)")

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Disconnect - not connected ")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).disconnect()

            return

        default:
            debugPrint("Error (didUpdateValueForTXMessage): Unsupported Type")
            return
        }
    }

    func didUpdateValueForTXLargeMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let mtu = mtus[peripheral.identifier.uuidString]?.mtu else {
            debugPrint("Error (didUpdateValueForTXLargeMessage): Mtu Unknown")
            return
        }

        let value = characteristic.value

        if let data = lotDatas[peripheral.identifier.uuidString + characteristic.uuid.uuidString], let value = value {
            debugPrint("→ Large Object Transfer - \(value) - \(counter)")
            lotDatas[peripheral.identifier.uuidString + characteristic.uuid.uuidString] = Data([UInt8](data) + [UInt8](value))
        } else if let value = value {
            debugPrint("→ Large Object Transfer - \(value) - \(counter)")
            lotDatas[peripheral.identifier.uuidString + characteristic.uuid.uuidString] = value
        }
        counter += 1

        if value?.count ?? 0 < mtu - 3 {
            let data = lotDatas[peripheral.identifier.uuidString + characteristic.uuid.uuidString]
            debugPrint("→ Large Object Transfer Finish \(data)")
            lotDatas[peripheral.identifier.uuidString + characteristic.uuid.uuidString] = nil
        }
    }

    func didUpdateValueForListNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let listNetworkResp = try? JSONDecoder().decode(ListNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForListNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(listNetworkResp)")

        if listNetworkResp.index < 0 {

            if let index = networks[peripheral.identifier.uuidString]?[0].firstIndex(where: { network -> Bool in
                network.ssid == listNetworkResp.ssid && network.bssid == listNetworkResp.bssid && network.security == listNetworkResp.security
            }) {
                networks[peripheral.identifier.uuidString]?[0][index].rssi = listNetworkResp.rssi
                networks[peripheral.identifier.uuidString]?[0][index].hidden = listNetworkResp.hidden
                return
            }

            networks[peripheral.identifier.uuidString]?[1].append(listNetworkResp)
            networks[peripheral.identifier.uuidString]?[1].sort(by: { networkA, networkB -> Bool in
                networkA.rssi > networkB.rssi
            })

        } else {
            networks[peripheral.identifier.uuidString]?[0].append(listNetworkResp)
            networks[peripheral.identifier.uuidString]?[0].sort(by: { networkA, networkB -> Bool in
                networkA.index < networkB.index
            })
        }

        NotificationCenter.default.post(name: .didListNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "listNetworkResp": listNetworkResp])
    }

    func didUpdateValueForSaveNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let saveNetworkResp = try? JSONDecoder().decode(SaveNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForSaveNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(saveNetworkResp)")
        NotificationCenter.default.post(name: .didSaveNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "saveNetworkResp": saveNetworkResp])
    }

    func didUpdateValueForEditNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let editNetworkResp = try? JSONDecoder().decode(EditNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForEditNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(editNetworkResp)")
        NotificationCenter.default.post(name: .didEditNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "editNetworkResp": editNetworkResp])
    }

    func didUpdateValueForDeleteNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let deleteNetworkResp = try? JSONDecoder().decode(DeleteNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForDeleteNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(deleteNetworkResp)")
        NotificationCenter.default.post(name: .didDeleteNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "deleteNetworkResp": deleteNetworkResp])
    }
}

extension AWSAfrManager {

    func debugPrint(_ debugMessage: String) {
        guard isDebug else {
            return
        }

        os_log("[FreeRTOS] %@", log: .default, type: .default, debugMessage)

        debugMessages += "[FreeRTOS] \(debugMessage)\n\n"
        NotificationCenter.default.post(name: .debugPrint, object: nil, userInfo: ["debugMessage": "[FreeRTOS] \(debugMessage)\n\n"])
    }
}
