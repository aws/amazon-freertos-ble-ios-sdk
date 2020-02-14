import AmazonFreeRTOS
import CoreBluetooth
import UIKit

/// Example 1: Mqtt Proxy
///
/// This example showcases how to start and stop the mqtt proxy service that allows mqtt messages from FreeRTOS device to be passed to AWS IoT.
class MqttProxyViewController: UIViewController {

    var uuid: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let uuid = uuid else {
            return
        }
        title = AmazonFreeRTOSManager.shared.devices[uuid]?.peripheral.name
    }
}
