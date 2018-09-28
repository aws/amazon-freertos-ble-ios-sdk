import AWSCore
import AWSIoT
import AWSMobileClient
import CoreBluetooth
import os.log
import UIKit

extension AWSAfrGattService {
    /// Custom BLE service, a counter that can start, stop and reset.
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

/**
 Example 3: Custom GATT and MQTT

 This example showcases how to use another GATT(BLE) and MQTT stack along side with the one that's in the AWSAfr SDK
 */
class CustomGattMqttViewController: UIViewController {

    @IBOutlet private var swMqttProxy: UISwitch!
    @IBOutlet private var btnStartCounter: UIButton!
    @IBOutlet private var btnStopCounter: UIButton!
    @IBOutlet private var btnResetCounter: UIButton!

    var peripheral: CBPeripheral?

    var customCentral: CBCentralManager?
    var customPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        addObservers()

        // Connect on load

        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.connectPeripheral(peripheral)

        title = peripheral.name

        // Custom GATT

        customCentral = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Disconnect on disappear

        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.disconnectPeripheral(peripheral)
    }
}

// Observer

extension CustomGattMqttViewController {

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverCharacteristics(_:)), name: .afrPeripheralDidDiscoverCharacteristics, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mqttProxyControl(_:)), name: .afrMqttProxyControl, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceInfoBrokerEndpoint(_:)), name: .afrDeviceInfoBrokerEndpoint, object: nil)
    }

    @objc
    func didDiscoverCharacteristics(_ notification: NSNotification) {
        guard let peripheral = peripheral else {
            return
        }

        if notification.userInfo?["service"] as? CBUUID == AWSAfrGattService.DeviceInfo {
            AWSAfrManager.shared.getBrokerEndpointOfPeripheral(peripheral)
        } else if notification.userInfo?["service"] as? CBUUID == AWSAfrGattService.MqttProxy {
            AWSAfrManager.shared.getMqttProxyControlOfPeripheral(peripheral)
        }
    }

    @objc
    func mqttProxyControl(_ notification: NSNotification) {
        guard let control = notification.userInfo?["control"] as? Control else {
            return
        }
        swMqttProxy.isEnabled = true
        swMqttProxy.setOn(control.proxyState == .on, animated: true)
    }

    @objc
    func deviceInfoBrokerEndpoint(_ notification: NSNotification) {
        guard let brokerEndpoint = notification.userInfo?["brokerEndpoint"] as? BrokerEndpoint else {
            return
        }

        // Custom MQTT

        guard let serviceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, endpoint: AWSEndpoint(urlString: "https://\(brokerEndpoint.brokerEndpoint)"), credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider()) else {
            os_log("[FreeRTOSDemo] Error (didUpdateValueFor): AWSServiceConfiguration")
            return
        }

        // Register a new AWSIoTDataManager with "uuidString_custom".

        guard let peripheral = peripheral else {
            return
        }
        AWSIoTDataManager.register(with: serviceConfiguration, forKey: "\(peripheral.identifier.uuidString)_custom")
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").disconnect()
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").connectUsingWebSocket(withClientId: peripheral.identifier.uuidString, cleanSession: true) { _ in }

        btnStartCounter.isEnabled = true
        btnStopCounter.isEnabled = true
        btnResetCounter.isEnabled = true
    }
}

// Custom GATT

extension CustomGattMqttViewController {

    func startScanForPeripherals() {
        if let customCentral = customCentral, !customCentral.isScanning {
            customCentral.scanForPeripherals(withServices: [AWSAfrGattService.DeviceInfo], options: [CBCentralManagerOptionShowPowerAlertKey: true])
        }
    }

    func stopScanForPeripherals() {
        if let customCentral = customCentral, customCentral.isScanning {
            customCentral.stopScan()
        }
    }
}

extension CustomGattMqttViewController: CBCentralManagerDelegate {

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
        if peripheral.identifier != self.peripheral?.identifier, peripheral.state == .disconnected {
            return
        }
        customPeripheral = peripheral
        central.connect(peripheral, options: nil)
    }

    // Connection

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        // You should only discover the custom service you want to use, DO NOT discover the FreeRTOS services.
        peripheral.discoverServices([AWSAfrGattService.Custom])
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral _: CBPeripheral, error: Error?) {
        if let error = error {
            os_log("[FreeRTOSDemo] Error (didDisconnectPeripheral): %@", log: .default, type: .default, error.localizedDescription)
        }
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

        // Send the message to the custom topic

        guard let value = characteristic.value, AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").getConnectionStatus() == .connected else {
            return
        }
        AWSIoTDataManager(forKey: "\(peripheral.identifier.uuidString)_custom").publishData(value, onTopic: AmazonConstants.AWS.mqttCustomTopic, qoS: AWSIoTMQTTQoS.messageDeliveryAttemptedAtLeastOnce)
    }
}

extension CustomGattMqttViewController {

    @IBAction private func btnDebugPush(_: UIBarButtonItem) {
        performSegue(withIdentifier: "toDebugViewController", sender: self)
    }

    @IBAction private func swMqttProxyValueChanged(_ sender: UISwitch) {
        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.getMtuOfPeripheral(peripheral)
        if sender.isOn {
            AWSAfrManager.shared.updateMqttProxyControlOfPeripheral(peripheral, control: Control(proxyState: .on))
            return
        }
        AWSAfrManager.shared.updateMqttProxyControlOfPeripheral(peripheral, control: Control(proxyState: .off))
    }

    // Custom MQTT

    @IBAction private func btnStartCounterPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AWSAfrGattService.Custom)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.start.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnStopCounterPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AWSAfrGattService.Custom)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.stop.rawValue)]), for: characteristic, type: .withResponse)
    }

    @IBAction private func btnResetCounterPush(_: UIButton) {
        guard let characteristic = customPeripheral?.serviceOf(uuid: AWSAfrGattService.Custom)?.characteristicOf(uuid: AWSAfrGattCharacteristic.DemoWrite) else {
            return
        }
        customPeripheral?.writeValue(Data([UInt8(GattDemo.reset.rawValue)]), for: characteristic, type: .withResponse)
    }
}
