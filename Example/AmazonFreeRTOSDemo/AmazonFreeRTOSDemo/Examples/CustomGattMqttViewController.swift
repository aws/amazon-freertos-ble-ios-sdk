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

/**
 Example 3: Custom GATT and MQTT

 This example showcases how to use another GATT(BLE) and MQTT stack along side with the one that's in the Amazon FreeRTOS SDK
 */
class CustomGattMqttViewController: UIViewController {

    @IBOutlet private var btnStartCounter: UIButton!
    @IBOutlet private var btnStopCounter: UIButton!
    @IBOutlet private var btnResetCounter: UIButton!

    var peripheral: CBPeripheral?

    var customCentral: CBCentralManager?
    var customPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Go back if device got disconnected
        NotificationCenter.default.addObserver(self, selector: #selector(centralManagerDidDisconnectPeripheral(_:)), name: .afrCentralManagerDidDisconnectPeripheral, object: nil)
        // Got the BrokerEndpoint from device
        NotificationCenter.default.addObserver(self, selector: #selector(deviceInfoBrokerEndpoint(_:)), name: .afrDeviceInfoBrokerEndpoint, object: nil)

        guard let peripheral = peripheral else {
            return
        }
        title = peripheral.name

        // Use the same IoT Broker Endpoint for custom mqtt
        AmazonFreeRTOSManager.shared.getBrokerEndpointOfPeripheral(peripheral)

        // Custom GATT
        customCentral = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

// Observer

extension CustomGattMqttViewController {

    @objc
    func centralManagerDidDisconnectPeripheral(_ notification: NSNotification) {
        if peripheral?.identifier == notification.userInfo?["peripheral"] as? UUID {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    @objc
    func deviceInfoBrokerEndpoint(_ notification: NSNotification) {
        guard let brokerEndpoint = notification.userInfo?["brokerEndpoint"] as? String else {
            return
        }

        // Custom MQTT

        guard let serviceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, endpoint: AWSEndpoint(urlString: "https://\(brokerEndpoint)"), credentialsProvider: AWSMobileClient.sharedInstance()) else {
            os_log("[FreeRTOS Demo] Error (AWSServiceConfiguration)", log: .default, type: .error)
            return
        }

        // Register a new AWSIoTDataManager with "uuidString_custom".

        guard let peripheral = peripheral else {
            return
        }
        AWSIoTDataManager.register(with: serviceConfiguration, forKey: "\(peripheral.identifier.uuidString)_custom")
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").disconnect()
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").connectUsingWebSocket(withClientId: peripheral.identifier.uuidString, cleanSession: true) { _ in }
    }
}

extension CustomGattMqttViewController: CBCentralManagerDelegate {

    // BLE state change

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn, let peripheral = peripheral, let retrievedPeripheral = central.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first {
            customPeripheral = retrievedPeripheral
            central.connect(retrievedPeripheral, options: nil)
        }
    }

    // Connection

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
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
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            os_log("[FreeRTOS Demo] Error (didDiscoverCharacteristicsFor): %@", log: .default, type: .error, error.localizedDescription)
            return
        }
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
