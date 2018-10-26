import Alertift
import AWSAuthCore
import AWSAuthUI
import AWSIoT
import CoreBluetooth
import UIKit

/**
 This is the main controller used to list the nearby Amazon FreeRTOS devices that has the BLE capability.
 */
class DevicesViewController: UITableViewController {

    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self

        // Add observe for AWSAfrManager NSNotifications

        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverPeripheral), name: .afrCentralManagerDidDiscoverPeripheral, object: nil)

        // Rescan peripherals using refreshControl

        refreshControl?.addTarget(self, action: #selector(rescanPeripherals), for: .valueChanged)
        refreshControl?.beginRefreshing()

        showLogin()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // Segue

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "toMqttProxyViewController", let viewController: MqttProxyViewController = segue.destination as? MqttProxyViewController {
            viewController.peripheral = peripheral
        } else if segue.identifier == "toNetworkConfigViewController", let viewController: NetworkConfigViewController = segue.destination as? NetworkConfigViewController {
            viewController.peripheral = peripheral
        } else if segue.identifier == "toCustomGattMqttViewController", let viewController: CustomGattMqttViewController = segue.destination as? CustomGattMqttViewController {
            viewController.peripheral = peripheral
        }
    }
}

extension DevicesViewController {

    @objc
    func didDiscoverPeripheral() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    @objc
    func rescanPeripherals() {
        AWSAfrManager.shared.rescanForPeripherals()
        tableView.reloadData()
    }

    func showLogin() {

        // Check if user is login

        guard let navigationController = navigationController, !AWSSignInManager.sharedInstance().isLoggedIn else {

            // -> User loged in, attach principal policy

            attachPrincipalPolicy()
            return
        }

        // -> User not loged in, present login ui.

        AWSAuthUIViewController.presentViewController(with: navigationController, configuration: nil) { _, error in
            if let error = error {
                Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                    .action(.default(NSLocalizedString("OK", comment: String())))
                    .show()
                return
            }

            // -> User loged in, attach principal policy

            self.attachPrincipalPolicy()
        }
    }

    #warning("attachPrincipalPolicy should NOT be done in the app, this is just for demo purposes. See getting started guide.")
    /**
     Attach the coginto identity to the AWS IoT policy.

     - Precondition: The AWS IoT policy must already have been created. Follow the get started guide if not.
     */
    func attachPrincipalPolicy() {
        guard let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest() else {
            return
        }
        // The AWS IoT Policy
        attachPrincipalPolicyRequest.policyName = AmazonConstants.AWS.iotPolicyName
        // The AWS Cognito Identity
        attachPrincipalPolicyRequest.principal = AWSIdentityManager.default().identityId

        AWSIoT.default().attachPrincipalPolicy(attachPrincipalPolicyRequest, completionHandler: { error in
            if let error = error {
                Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                    .action(.default(NSLocalizedString("OK", comment: String())))
                    .show()
                return
            }
        })
    }
}

// UITableView

extension DevicesViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.backgroundColor = .white
        if AWSAfrManager.shared.peripherals.isEmpty {
            tableView.backgroundColor = .clear
        }
        return AWSAfrManager.shared.peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        guard let devicesCell = cell as? DeviceCell else {
            return cell
        }
        let device = Array(AWSAfrManager.shared.peripherals.values)[indexPath.row]
        devicesCell.labPeripheralName.text = device.name
        // iOS use generated identifier, it will be different on other devices.
        devicesCell.labPeripheralUUID.text = device.identifier.uuidString
        return devicesCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        peripheral = Array(AWSAfrManager.shared.peripherals.values)[indexPath.row]
        Alertift.actionSheet()
            .popover(anchorView: cell)

            // Example 1: MQTT Proxy

            .action(.default(NSLocalizedString("MQTT Proxy", comment: String()))) { _, _ in
                self.performSegue(withIdentifier: "toMqttProxyViewController", sender: self)
                return
            }

            // Example 2: Network Config

            .action(.default(NSLocalizedString("Network Config", comment: String()))) { _, _ in
                self.performSegue(withIdentifier: "toNetworkConfigViewController", sender: self)
                return
            }

            // Example 3: Custom GATT MQTT

            .action(.default(NSLocalizedString("Custom GATT MQTT", comment: String()))) { _, _ in
                self.performSegue(withIdentifier: "toCustomGattMqttViewController", sender: self)
                return
            }
            .action(.cancel(NSLocalizedString("Cancel", comment: String())))
            .show()
    }
}

extension DevicesViewController {

    @IBAction private func btnLogoutPush(_: UIBarButtonItem) {
        AWSSignInManager.sharedInstance().logout(completionHandler: { _, _ in
            self.showLogin()
        })
    }
}
