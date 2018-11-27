import AmazonFreeRTOS
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

        // Update the switch when mqtt proxy is turned on or off
        NotificationCenter.default.addObserver(self, selector: #selector(mqttProxyControl(_:)), name: .afrMqttProxyControl, object: nil)

        guard let peripheral = peripheral else {
            return
        }
        title = peripheral.name

        // Check if mqtt proxy is on
        AmazonFreeRTOSManager.shared.getMqttProxyControlOfPeripheral(peripheral)
    }
}

// Observer

extension MqttProxyViewController {

    @objc
    func mqttProxyControl(_ notification: NSNotification) {
        guard let control = notification.userInfo?["control"] as? MqttProxyControl else {
            return
        }
        swMqttProxy.isEnabled = true
        swMqttProxy.setOn(control.proxyState == .on, animated: true)
    }
}

extension MqttProxyViewController {

    @IBAction private func swMqttProxyValueChanged(_ sender: UISwitch) {
        guard let peripheral = peripheral else {
            return
        }

        // Get MTU again just in case we didnt get the notification
        AmazonFreeRTOSManager.shared.getMtuOfPeripheral(peripheral)

        if sender.isOn {

            // Turn on mqtt proxy
            AmazonFreeRTOSManager.shared.updateMqttProxyControlOfPeripheral(peripheral, mqttProxyControl: MqttProxyControl(proxyState: .on))
            return
        }
        // Turn off mqtt proxy
        AmazonFreeRTOSManager.shared.updateMqttProxyControlOfPeripheral(peripheral, mqttProxyControl: MqttProxyControl(proxyState: .off))
    }
}
