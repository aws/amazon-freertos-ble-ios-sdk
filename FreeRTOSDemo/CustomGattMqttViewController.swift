import AWSCore
import AWSIoT
import AWSMobileClient
import CoreBluetooth
import os.log
import UIKit

extension AWSAfrGattService {
    static let Custom = CBUUID(string: "c6f2d9e3-49e7-4125-9014-bfc6d669ff00")
}

extension AWSAfrGattCharacteristic {
    static let DemoRead = CBUUID(string: "c6f2d9e3-49e7-4125-9014-bfc6d669ff01")
    static let DemoWrite = CBUUID(string: "c6f2d9e3-49e7-4125-9014-bfc6d669ff02")
}

enum GattDemo: Int {
    case start = 0
    case stop = 1
    case reset = 2
}

class CustomGattMqttViewController: UIViewController {

    var peripheral: CBPeripheral?

    var customCentral: CBCentralManager?
    var customPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let peripheral = peripheral else {
            return
        }

        addObservers()

        title = peripheral.name
        AWSAfrManager.shared.connectPeripheral(peripheral)

        // custom gatt

        customCentral = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])

        // custom mqtt

        guard let serviceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, endpoint: AmazonConstants.AWS.iotEndpoint, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider()) else {
            os_log("[FreeRTOSDemo] Error (didUpdateValueFor): AWSServiceConfiguration")
            return
        }

        AWSIoTDataManager.register(with: serviceConfiguration, forKey: "\(peripheral.identifier.uuidString)_custom")
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").disconnect()
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").connectUsingWebSocket(withClientId: peripheral.identifier.uuidString, cleanSession: true) { _ in }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.disconnectPeripheral(peripheral)
    }
}

// Observer

extension CustomGattMqttViewController {

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverCharacteristics(_:)), name: .didDiscoverCharacteristics, object: nil)
    }

    @objc
    func didDiscoverCharacteristics(_ notification: NSNotification) {
        guard let peripheral = peripheral, notification.userInfo?["service"] as? CBUUID == AWSAfrGattService.Mqtt else {
            return
        }
        AWSAfrManager.shared.startMqttOfPeripheral(peripheral)
    }
}

extension CustomGattMqttViewController {

    func startScanForPeripherals() {
        if let customCentral = customCentral, !customCentral.isScanning {
            customCentral.scanForPeripherals(withServices: [AWSAfrGattService.FreeRTOS], options: [CBCentralManagerOptionShowPowerAlertKey: true])
        }
    }

    func stopScanForPeripherals() {
        if let customCentral = customCentral, customCentral.isScanning {
            customCentral.stopScan()
        }
    }
}

extension CustomGattMqttViewController: CBCentralManagerDelegate {

    // Ble state change

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanForPeripherals()
            return
        }
        stopScanForPeripherals()
    }

    // Scan

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        if peripheral.identifier != self.peripheral?.identifier, peripheral.state == .disconnected {
            return
        }
        customPeripheral = peripheral
        central.connect(peripheral, options: nil)
    }

    // Connect

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([AWSAfrGattService.Custom])
    }

    func centralManager(_: CBCentralManager, didFailToConnect _: CBPeripheral, error: Error?) {
        if let error = error {
            os_log("[FreeRTOSDemo] Error (didFailToConnect): %@", log: .default, type: .default, error.localizedDescription)
        }
    }
}

extension CustomGattMqttViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log("[FreeRTOSDemo] Error (didDiscoverServices): %@", log: .default, type: .default, error.localizedDescription)
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            os_log("[FreeRTOSDemo] Error (didDiscoverCharacteristicsFor): %@", log: .default, type: .default, error.localizedDescription)
            return
        }
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            os_log("[FreeRTOSDemo] Error (didUpdateValueFor): %@", log: .default, type: .default, error.localizedDescription)
            return
        }

        guard let value = characteristic.value, AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").getConnectionStatus() == .connected else {
            return
        }
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").publishData(value, onTopic: AmazonConstants.AWS.mqttCustomTopic, qoS: AWSIoTMQTTQoS.messageDeliveryAttemptedAtLeastOnce)
    }
}

extension CustomGattMqttViewController {

    @IBAction private func btnStartPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AWSAfrGattService.Custom)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.start.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnStopPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AWSAfrGattService.Custom)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.stop.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnResetPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AWSAfrGattService.Custom)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.reset.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnDebugPush(_: UIBarButtonItem) {
        performSegue(withIdentifier: "toDebugViewController", sender: self)
    }
}
