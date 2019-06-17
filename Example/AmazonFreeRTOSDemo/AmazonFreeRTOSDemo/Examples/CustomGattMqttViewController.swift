import AmazonFreeRTOS
import AWSIoT
import AWSMobileClient
import CoreBluetooth
import os.log
import UIKit

extension AmazonFreeRTOSGattService {
    /// Custom BLE service, a counter that can start, stop and reset.
    static let Custom = CBUUID(string: "c6f2d9e3-49e7-4125-9014-bfc6d669ff00")
}

extension AmazonFreeRTOSGattCharacteristic {
    static let DemoRead = CBUUID(string: "c6f2d9e3-49e7-4125-9014-bfc6d669ff01")
    static let DemoWrite = CBUUID(string: "c6f2d9e3-49e7-4125-9014-bfc6d669ff02")
}

enum GattDemo: Int {
    case start = 0
    case stop = 1
    case reset = 2
}

/// Example 3: Custom GATT and MQTT
///
/// This example showcases how to use another GATT(BLE) and MQTT stack along side with the one that's in the Amazon FreeRTOS SDK
class CustomGattMqttViewController: UIViewController {

    @IBOutlet private var btnStartCounter: UIButton!
    @IBOutlet private var btnStopCounter: UIButton!
    @IBOutlet private var btnResetCounter: UIButton!

    var uuid: UUID?

    var customCentral: CBCentralManager?
    var customPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let uuid = uuid else {
            return
        }
        title = AmazonFreeRTOSManager.shared.devices[uuid]?.peripheral.name

        // Custom GATT

        customCentral = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])

        // Custom MQTT

        guard let brokerEndpoint = AmazonFreeRTOSManager.shared.devices[uuid]?.brokerEndpoint, let serviceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, endpoint: AWSEndpoint(urlString: "https://\(brokerEndpoint)"), credentialsProvider: AWSMobileClient.sharedInstance()) else {
            os_log("[FreeRTOS Demo] Error can't create serviceConfiguration", log: .default, type: .error)
            return
        }

        // Register a new AWSIoTDataManager with "uuidString_custom".

        AWSIoTDataManager.register(with: serviceConfiguration, forKey: "\(uuid.uuidString)_custom")
        AWSIoTDataManager(forKey: "\(uuid.uuidString)_custom").disconnect()
        AWSIoTDataManager(forKey: "\(uuid.uuidString)_custom").connectUsingWebSocket(withClientId: uuid.uuidString, cleanSession: true) { status in
            os_log("[FreeRTOS Demo] connectUsingWebSocket status: %d", log: .default, type: .default, status.rawValue)
        }
    }
}

extension CustomGattMqttViewController: CBCentralManagerDelegate {

    // BLE state change

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let uuid = uuid, central.state == .poweredOn, let retrievedPeripheral = central.retrievePeripherals(withIdentifiers: [uuid]).first else {
            os_log("[FreeRTOS Demo] Error can't retrievePeripherals", log: .default, type: .error)
            return
        }
        customPeripheral = retrievedPeripheral
        central.connect(retrievedPeripheral, options: nil)
    }

    // Connection

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("[FreeRTOS Demo] didConnect", log: .default, type: .default)
        peripheral.delegate = self
        // You should only discover the custom service you want to use, DO NOT discover the FreeRTOS services.
        peripheral.discoverServices([AmazonFreeRTOSGattService.Custom])
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral _: CBPeripheral, error: Error?) {
        if let error = error {
            os_log("[FreeRTOS Demo] Error (didDisconnectPeripheral): %@", log: .default, type: .error, error.localizedDescription)
        }
    }

    func centralManager(_: CBCentralManager, didFailToConnect _: CBPeripheral, error: Error?) {
        if let error = error {
            os_log("[FreeRTOS Demo] Error (didFailToConnect): %@", log: .default, type: .error, error.localizedDescription)
        }
    }
}

extension CustomGattMqttViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log("[FreeRTOS Demo] Error (didDiscoverServices): %@", log: .default, type: .error, error.localizedDescription)
            return
        }
        os_log("[FreeRTOS Demo] didDiscoverServices", log: .default, type: .default)
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            os_log("[FreeRTOS Demo] Error (didDiscoverCharacteristics): %@", log: .default, type: .error, error.localizedDescription)
            return
        }
        os_log("[FreeRTOS Demo] didDiscoverCharacteristics", log: .default, type: .default)
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }

        // Enable the UI

        btnStartCounter.isEnabled = true
        btnStopCounter.isEnabled = true
        btnResetCounter.isEnabled = true
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            os_log("[FreeRTOS Demo] Error (didUpdateValueFor): %@", log: .default, type: .error, error.localizedDescription)
            return
        }

        // Send the message to the custom topic

        guard let value = characteristic.value, AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").getConnectionStatus() == .connected else {
            return
        }
        os_log("[FreeRTOS Demo] Value: %@", log: .default, type: .debug, String(data: value, encoding: .utf8) ?? String())
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").publishData(value, onTopic: AmazonConstants.AWS.mqttCustomTopic, qoS: AWSIoTMQTTQoS.messageDeliveryAttemptedAtLeastOnce)
    }
}

extension CustomGattMqttViewController {

    // Custom MQTT

    @IBAction private func btnStartCounterPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AmazonFreeRTOSGattService.Custom)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.start.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnStopCounterPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AmazonFreeRTOSGattService.Custom)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.stop.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnResetCounterPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AmazonFreeRTOSGattService.Custom)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.reset.rawValue)]), for: characteristic, type: .withResponse)
    }
}
