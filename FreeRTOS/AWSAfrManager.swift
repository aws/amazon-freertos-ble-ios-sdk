import AWSCore
import AWSIoT
import AWSMobileClient
import CoreBluetooth
import Foundation
import os.log

class AWSAfrManager: NSObject {

    /// Shared instence of Amazon FreeRTOS Manager.
    static let shared = AWSAfrManager()

    #warning("dev delete")

    var isDebug: Bool = false
    var debugMessages = String()
    var counter = 0

    #warning("dev delete")

    // BLE Central Manager for the SDK
    private var central: CBCentralManager?

    /// The peripherals using peripheral identifier as key.
    var peripherals: [String: CBPeripheral] = [:]
    /// The mtus for peripherals using peripheral identifier as key.
    var mtus: [String: Mtu] = [:]
    /// The broker endpoints for peripherals using peripheral identifier as key.
    var brokerEndpoints: [String: BrokerEndpoint] = [:]
    /// The networks peripherals scaned using peripheral identifier as key.
    var networks: [String: [[ListNetworkResp]]] = [:]

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

    /**
     Start scan for FreeRTOS peripherals.

     - Precondition: `central` is ready and not scanning.
     */
    func startScanForPeripherals() {
        if let central = central, !central.isScanning {
            central.scanForPeripherals(withServices: [AWSAfrGattService.DeviceInfo], options: nil)
        }
    }

    /**
     Stop scan for FreeRTOS peripherals.

     - Precondition: `central` is ready and is scanning.
     */
    func stopScanForPeripherals() {
        if let central = central, central.isScanning {
            central.stopScan()
        }
    }

    /// Rescan for FreeRTOS peripherals and clear all contexts.
    func rescanForPeripherals() {
        stopScanForPeripherals()

        peripherals.removeAll()
        mtus.removeAll()
        brokerEndpoints.removeAll()
        networks.removeAll()

        lotDatas.removeAll()

        startScanForPeripherals()
    }

    /**
     Connect to FreeRTOS `peripheral`

     - Parameter peripheral: the FreeRTOS peripheral.
     - Precondition: `central` is ready and `peripheral` must be disconnected.
     */
    func connectPeripheral(_ peripheral: CBPeripheral) {
        if let central = central, peripheral.state == .disconnected {
            central.connect(peripheral, options: nil)
        }
    }

    /**
     Disconnect from FreeRTOS `peripheral`

     - Parameter peripheral: the FreeRTOS peripheral.
     - Precondition: `central` is ready and `peripheral` must be connected.
     */
    func disconnectPeripheral(_ peripheral: CBPeripheral) {
        if let central = central, peripheral.state == .connected {
            central.cancelPeripheralConnection(peripheral)
        }
    }

    // Mqtt Proxy Service

    /**
     Control the mqtt proxying of `peripheral` such as start and stop the proxy.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - controlMessage: The control message.
     */
    func controlMqttOfPeripheral(_ peripheral: CBPeripheral, controlMessage: ControlMessage) {

        debugPrint("↓ \(controlMessage)")

        guard let data = try? JSONEncoder().encode(controlMessage) else {
            debugPrint("Error (controlMqttOfPeripheral): Invalid ControlMessage")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.MqttProxy)?.characteristicOf(uuid: AWSAfrGattCharacteristic.Control) else {
            debugPrint("Error (controlMqttOfPeripheral): MqttProxy service or Control characteristic doesn't exist")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    // Network Config Service

    /**
     List saved and scanned wifi networks of `peripheral`. Wifi networks are returned one by one, saved wifi ordered by priority and scanned wifi ordered by signal strength (rssi)

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - listNetworkReq: The list network request.
     */
    func listNetworkOfPeripheral(_ peripheral: CBPeripheral, listNetworkReq: ListNetworkReq) {

        debugPrint("↓ \(listNetworkReq)")

        // reset networks list for the peripheral
        networks[peripheral.identifier.uuidString] = [[], []]

        guard let data = try? JSONEncoder().encode(listNetworkReq) else {
            debugPrint("Error (listNetworkOfPeripheral): Invalid ListNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.NetworkConfig)?.characteristicOf(uuid: AWSAfrGattCharacteristic.ListNetwork) else {
            debugPrint("Error (listNetworkOfPeripheral): NetworkConfig service or ListNetwork characteristic doesn't exist")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    /**
     Save wifi network to `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - saveNetworkReq: The save network request
     */
    func saveNetworkToPeripheral(_ peripheral: CBPeripheral, saveNetworkReq: SaveNetworkReq) {

        debugPrint("↓ \(saveNetworkReq)")

        guard let data = try? JSONEncoder().encode(saveNetworkReq) else {
            debugPrint("Error (saveNetworkToPeripheral): Invalid SaveNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.NetworkConfig)?.characteristicOf(uuid: AWSAfrGattCharacteristic.SaveNetwork) else {
            debugPrint("Error (saveNetworkToPeripheral): NetworkConfig service or SaveNetwork characteristic doesn't exist")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    /**
     Edit wifi network of `peripheral`. Currently only support priority change

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - editNetworkReq: The edit network request
     */
    func editNetworkOfPeripheral(_ peripheral: CBPeripheral, editNetworkReq: EditNetworkReq) {

        debugPrint("↓ \(editNetworkReq)")

        guard let data = try? JSONEncoder().encode(editNetworkReq) else {
            debugPrint("Error (editNetworkOfPeripheral): Invalid EditNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.NetworkConfig)?.characteristicOf(uuid: AWSAfrGattCharacteristic.EditNetwork) else {
            debugPrint("Error (editNetworkOfPeripheral): NetworkConfig service or EditNetwork characteristic doesn't exist")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    /**
     Delete saved wifi network from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - deleteNetworkReq: The delete network request
     */
    func deleteNetworkFromPeripheral(_ peripheral: CBPeripheral, deleteNetworkReq: DeleteNetworkReq) {

        debugPrint("↓ \(deleteNetworkReq)")

        guard let data = try? JSONEncoder().encode(deleteNetworkReq) else {
            debugPrint("Error (deleteNetworkFromPeripheral): Invalid DeleteNetworkReq")
            return
        }
        guard let characteristic = peripheral.serviceOf(uuid: AWSAfrGattService.NetworkConfig)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DeleteNetwork) else {
            debugPrint("Error (deleteNetworkFromPeripheral): NetworkConfig service or DeleteNetwork characteristic doesn't exist")
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// This section are the methods for CBCentralManagerDelegate.
extension AWSAfrManager: CBCentralManagerDelegate {

    // BLE state change

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanForPeripherals()
            return
        }
        stopScanForPeripherals()
    }

    // Discover

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        debugPrint("→ \(advertisementData)")
        if peripherals.keys.contains(peripheral.identifier.uuidString) {
            return
        }
        peripherals[peripheral.identifier.uuidString] = peripheral
        NotificationCenter.default.post(name: .didDiscoverPeripheral, object: nil, userInfo: ["peripheral": peripheral.identifier])
    }

    // Connection

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        networks[peripheral.identifier.uuidString] = [[], []]
        peripheral.delegate = self
        peripheral.discoverServices([AWSAfrGattService.DeviceInfo, AWSAfrGattService.MqttProxy, AWSAfrGattService.NetworkConfig])
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            debugPrint("Error (central_didDisconnectPeripheral): \(error.localizedDescription)")
        }
        networks.removeValue(forKey: peripheral.identifier.uuidString)
        AWSIoTDataManager(forKey: peripheral.identifier.uuidString).disconnect()
    }

    func centralManager(_: CBCentralManager, didFailToConnect _: CBPeripheral, error: Error?) {
        if let error = error {
            debugPrint("Error (central_didFailToConnect): \(error.localizedDescription)")
        }
    }
}

// This section are the methods for CBPeripheralDelegate.
extension AWSAfrManager: CBPeripheralDelegate {

    // Discover

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            debugPrint("Error (peripheral_didDiscoverServices): \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        NotificationCenter.default.post(name: .didDiscoverServices, object: nil, userInfo: ["peripheral": peripheral.identifier])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            debugPrint("Error (peripheral_didDiscoverCharacteristicsForService): \(error.localizedDescription)")
            return
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }
        NotificationCenter.default.post(name: .didDiscoverCharacteristics, object: nil, userInfo: ["peripheral": peripheral.identifier, "service": service.uuid])
    }

    // Read, Write

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugPrint("Error (peripheral_didUpdateValueForCharacteristic): \(error.localizedDescription)")
            return
        }

        switch characteristic.uuid {

            // Device Info Service

        case AWSAfrGattCharacteristic.DeviceInfo:
            didUpdateValueForDeviceInfo(peripheral: peripheral, characteristic: characteristic)

            // Mqtt Proxy Service

        case AWSAfrGattCharacteristic.TXMessage:
            didUpdateValueForTXMessage(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.TXLargeMessage:
            didUpdateValueForTXLargeMessage(peripheral: peripheral, characteristic: characteristic)

            // Network Config Service

        case AWSAfrGattCharacteristic.ListNetwork:
            didUpdateValueForListNetwork(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.SaveNetwork:
            didUpdateValueForSaveNetwork(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.EditNetwork:
            didUpdateValueForEditNetwork(peripheral: peripheral, characteristic: characteristic)

        case AWSAfrGattCharacteristic.DeleteNetwork:
            didUpdateValueForDeleteNetwork(peripheral: peripheral, characteristic: characteristic)

        default:
            debugPrint("Error (peripheral_didUpdateValueForCharacteristic): Unsupported Characteristic")
            return
        }
    }

    func peripheral(_: CBPeripheral, didWriteValueFor _: CBCharacteristic, error: Error?) {
        if let error = error {
            debugPrint("Error (peripheral_didWriteValueForCharacteristic): \(error.localizedDescription)")
            return
        }
    }
}

// This section are the methods for processing the data.
extension AWSAfrManager {

    // Device Info Service

    /**
     Process data of DeviceInfo characteristic from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The DeviceInfo characteristic.
     */
    func didUpdateValueForDeviceInfo(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let deviceInfoMessage = try? JSONDecoder().decode(DeviceInfoMessage.self, from: value) else {
            debugPrint("Error (didUpdateValueForDeviceInfo): Invalid DeviceInfo Message")
            return
        }

        switch deviceInfoMessage.type {

        case .mtu:
            guard let mtu = try? JSONDecoder().decode(Mtu.self, from: value) else {
                debugPrint("Error (didUpdateValueForDeviceInfo): Invalid Mtu")
                return
            }
            debugPrint("→ \(mtu)")
            mtus[peripheral.identifier.uuidString] = mtu

        case .brokerEndpoint:
            guard let brokerEndpoint = try? JSONDecoder().decode(BrokerEndpoint.self, from: value) else {
                debugPrint("Error (didUpdateValueForDeviceInfo): Invalid BrokerEndpoint")
                return
            }
            debugPrint("→ \(brokerEndpoint)")
            brokerEndpoints[peripheral.identifier.uuidString] = brokerEndpoint
        }
    }

    // Mqtt Proxy Service

    /**
     Process data of TXMessage characteristic from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The TXMessage characteristic.
     */
    func didUpdateValueForTXMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic) {

        guard let value = characteristic.value, let mqttProxyMessage = try? JSONDecoder().decode(MqttProxyMessage.self, from: value) else {
            debugPrint("Error (didUpdateValueForTXMessage): Invalid MqttProxy Message")
            return
        }

        switch mqttProxyMessage.type {

        case .connect:

            guard let connect = try? JSONDecoder().decode(Connect.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect")
                return
            }

            debugPrint("↑ \(connect)")

            guard let region = connect.brokerEndpoint.split(separator: ".").object(at: 2) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect - broker endpoint region")
                return
            }

            guard let serviceConfiguration = AWSServiceConfiguration(region: String(region).aws_regionTypeValue(), endpoint: AWSEndpoint(urlString: "https://\(connect.brokerEndpoint)"), credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider()) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect - serviceConfiguration")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() != .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Connect - AWSIoTDataManager already connected")
                return
            }

            AWSIoTDataManager.register(with: serviceConfiguration, forKey: peripheral.identifier.uuidString)
            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).connectUsingWebSocket(withClientId: connect.clientID, cleanSession: connect.cleanSession) { status in

                switch status {

                case .connected:

                    let connack = Connack(type: .connack, status: status.rawValue)

                    self.debugPrint("↓ \(connack)")

                    guard let data = try? JSONEncoder().encode(connack) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Connack")
                        return
                    }
                    DispatchQueue.main.async {
                        guard peripheral.state == .connected else {
                            self.debugPrint("Error (writeValueForCharacteristic): Invalid Connack - peripheral no longer connected")
                            return
                        }
                        guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                            self.debugPrint("Error (writeValueForCharacteristic): Invalid Connack - RXMessage characteristic doesn't exist")
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

            guard let data = Data(base64Encoded: publish.payloadVal) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - base64 decode")
                return
            }
            debugPrint("Base64Decode (didUpdateValueForTXMessage): \(publish.payloadVal.base64Decoded() ?? String())")
            guard let topic = publish.topic.base64Decoded() else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - topic")
                return
            }
            guard let qoS = AWSIoTMQTTQoS(rawValue: publish.qoS) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - qos")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Publish - AWSIoTDataManager not connected")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).publishData(data, onTopic: topic, qoS: qoS) {

                let puback = Puback(type: .puback, msgID: publish.msgID)

                self.debugPrint("↓ \(puback)")

                guard let data = try? JSONEncoder().encode(puback) else {
                    self.debugPrint("Error (writeValueForCharacteristic): Invalid Puback")
                    return
                }
                DispatchQueue.main.async {
                    guard peripheral.state == .connected else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Puback - peripheral no longer connected")
                        return
                    }
                    guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Puback - RXMessage characteristic doesn't exist")
                        return
                    }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                }
            }

        case .puback:
            // need aws iot sdk change, current it auto send puback when recived at sdk side.
            return

        case .subscribe:

            guard let subscribe = try? JSONDecoder().decode(Subscribe.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe")
                return
            }

            debugPrint("↑ \(subscribe)")

            guard let topic = subscribe.topic.base64Decoded() else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe - topic")
                return
            }
            guard let qoS = AWSIoTMQTTQoS(rawValue: subscribe.qoS) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe - qos")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Subscribe - AWSIoTDataManager not connected")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).subscribe(toTopic: topic, qoS: qoS, messageCallback: { data in

                let publish = Publish(type: .publish, topic: topic, msgID: subscribe.msgID, qoS: subscribe.qoS, payloadVal: data.base64EncodedString())

                self.debugPrint("↓ \(publish)")

                guard let data = try? JSONEncoder().encode(publish) else {
                    self.debugPrint("Error (writeValueForCharacteristic): Invalid Publish")
                    return
                }
                DispatchQueue.main.async {
                    guard peripheral.state == .connected else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Publish - peripheral no longer connected")
                        return
                    }
                    guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Publish - RXMessage characteristic doesn't exist")
                        return
                    }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                }

            }, ackCallback: {

                let suback = Suback(type: .suback, msgID: subscribe.msgID, status: subscribe.qoS)

                self.debugPrint("↓ \(suback)")

                guard let data = try? JSONEncoder().encode(suback) else {
                    self.debugPrint("Error (writeValueForCharacteristic): Invalid Suback")
                    return
                }
                DispatchQueue.main.async {
                    guard peripheral.state == .connected else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Suback - peripheral no longer connected")
                        return
                    }
                    guard let characteristic = characteristic.service.characteristicOf(uuid: AWSAfrGattCharacteristic.RXMessage) else {
                        self.debugPrint("Error (writeValueForCharacteristic): Invalid Suback - RXMessage characteristic doesn't exist")
                        return
                    }
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                }
            })

        case .unsubscribe:

            guard let unsubscribe = try? JSONDecoder().decode(Unsubscribe.self, from: value) else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Unsubscribe")
                return
            }

            debugPrint("↑ \(unsubscribe)")

            guard let topic = unsubscribe.topic.base64Decoded() else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Unsubscribe - topic")
                return
            }

            guard AWSIoTDataManager(forKey: peripheral.identifier.uuidString).getConnectionStatus() == .connected else {
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Unsubscribe - AWSIoTDataManager not connected")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).unsubscribeTopic(topic)

            let unsuback = Unsuback(type: .unsuback, msgID: unsubscribe.msgID)

            debugPrint("↓ \(unsuback)")

            guard let data = try? JSONEncoder().encode(unsuback) else {
                debugPrint("Error (writeValueForCharacteristic): Invalid Unsuback")
                return
            }

            guard peripheral.state == .connected else {
                debugPrint("Error (writeValueForCharacteristic): Invalid Suback - peripheral no longer connected")
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
                debugPrint("Error (didUpdateValueForTXMessage): Invalid Disconnect - AWSIoTDataManager not connected")
                return
            }

            AWSIoTDataManager(forKey: peripheral.identifier.uuidString).disconnect()

        default:
            debugPrint("Error (didUpdateValueForTXMessage): Unsupported Mqtt Proxy Message Type")
        }
    }

    /**
     Process data of TXLargeMessage characteristic from `peripheral`. Used by large object transfer.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The TXMessage characteristic.
     */
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
            debugPrint("→ Large Object Transfer Finish \(data ?? Data())")
            lotDatas[peripheral.identifier.uuidString + characteristic.uuid.uuidString] = nil
        }
    }

    // Network Config Service

    /**
     Process data of ListNetwork characteristic from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The ListNetwork characteristic.
     */
    func didUpdateValueForListNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let listNetworkResp = try? JSONDecoder().decode(ListNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForListNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(listNetworkResp)")

        if listNetworkResp.index < 0 {

            // Scaned networks also include saved networks so we filter that out when ssid, bssid and security are the same

            if let index = networks[peripheral.identifier.uuidString]?[0].firstIndex(where: { network -> Bool in
                network.ssid == listNetworkResp.ssid && network.bssid == listNetworkResp.bssid && network.security == listNetworkResp.security
            }) {
                networks[peripheral.identifier.uuidString]?[0][index].rssi = listNetworkResp.rssi
                networks[peripheral.identifier.uuidString]?[0][index].hidden = listNetworkResp.hidden
                return
            }

            // Scaned networks sorted by rssi
            
            networks[peripheral.identifier.uuidString]?[1].append(listNetworkResp)
            networks[peripheral.identifier.uuidString]?[1].sort(by: { networkA, networkB -> Bool in
                networkA.rssi > networkB.rssi
            })

        } else {
            
            // Saved networks sorted by index
            
            networks[peripheral.identifier.uuidString]?[0].append(listNetworkResp)
            networks[peripheral.identifier.uuidString]?[0].sort(by: { networkA, networkB -> Bool in
                networkA.index < networkB.index
            })
        }
        NotificationCenter.default.post(name: .didListNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "listNetworkResp": listNetworkResp])
    }

    /**
     Process data of SaveNetwork characteristic from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The SaveNetwork characteristic.
     */
    func didUpdateValueForSaveNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let saveNetworkResp = try? JSONDecoder().decode(SaveNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForSaveNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(saveNetworkResp)")
        NotificationCenter.default.post(name: .didSaveNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "saveNetworkResp": saveNetworkResp])
    }

    /**
     Process data of EditNetwork characteristic from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The EditNetwork characteristic.
     */
    func didUpdateValueForEditNetwork(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let value = characteristic.value, let editNetworkResp = try? JSONDecoder().decode(EditNetworkResp.self, from: value) else {
            debugPrint("Error (didUpdateValueForEditNetwork): Invalid Message")
            return
        }
        debugPrint("→ \(editNetworkResp)")
        NotificationCenter.default.post(name: .didEditNetwork, object: nil, userInfo: ["peripheral": peripheral.identifier, "editNetworkResp": editNetworkResp])
    }

    /**
     Process data of DeleteNetwork characteristic from `peripheral`.

     - Parameters:
     - peripheral: the FreeRTOS peripheral.
     - characteristic: The DeleteNetwork characteristic.
     */
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

    #warning("dev delete")

    func debugPrint(_ debugMessage: String) {
        guard isDebug else {
            return
        }

        os_log("[FreeRTOS] %@", log: .default, type: .default, debugMessage)

        debugMessages += "[FreeRTOS] \(debugMessage)\n\n"
        NotificationCenter.default.post(name: .debugPrint, object: nil, userInfo: ["debugMessage": "[FreeRTOS] \(debugMessage)\n\n"])
    }
}
