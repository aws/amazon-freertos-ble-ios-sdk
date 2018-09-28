import CoreBluetooth
import UIKit

/**
 Example 1: Mqtt Proxy

 This example showcases how to start and stop the mqtt proxy service that allows mqtt messages from Amazon FreeRTOS device to be passed to AWS IoT.
 */
class MqttProxyViewController: UIViewController {

    @IBOutlet private var swMqttProxy: UISwitch!

    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        addObservers()

        // Connect on load

        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.connectPeripheral(peripheral)

        title = peripheral.name
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

extension MqttProxyViewController {

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverCharacteristics(_:)), name: .afrPeripheralDidDiscoverCharacteristics, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mqttProxyControl(_:)), name: .afrMqttProxyControl, object: nil)
    }

    @objc
    func didDiscoverCharacteristics(_ notification: NSNotification) {
        guard notification.userInfo?["service"] as? CBUUID == AWSAfrGattService.MqttProxy else {
            return
        }

        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.getMqttProxyControlOfPeripheral(peripheral)
    }

    @objc
    func mqttProxyControl(_ notification: NSNotification) {
        guard let control = notification.userInfo?["control"] as? Control else {
            return
        }
        swMqttProxy.isEnabled = true
        swMqttProxy.setOn(control.proxyState == .on, animated: true)
    }
}

extension MqttProxyViewController {

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
}
