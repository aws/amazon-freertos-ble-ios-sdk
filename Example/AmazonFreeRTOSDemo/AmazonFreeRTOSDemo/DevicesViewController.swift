import Alertift
import AmazonFreeRTOS
import AWSIoT
import AWSMobileClient
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
        extendedLayoutIncludesOpaqueBars = true

        // Add observe for AmazonFreeRTOSManager NSNotifications

        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWithoutAnimation), name: .afrCentralManagerDidUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWithoutAnimation), name: .afrCentralManagerDidDiscoverPeripheral, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWithoutAnimation), name: .afrCentralManagerDidConnectPeripheral, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWithoutAnimation), name: .afrCentralManagerDidDisconnectPeripheral, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWithoutAnimation), name: .afrCentralManagerDidFailToConnectPeripheral, object: nil)

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
        if segue.identifier == "toMqttProxyViewController", let viewController = segue.destination as? MqttProxyViewController {
            viewController.peripheral = peripheral
        } else if segue.identifier == "toNetworkConfigViewController", let viewController = segue.destination as? NetworkConfigViewController {
            viewController.peripheral = peripheral
        } else if segue.identifier == "toCustomGattMqttViewController", let viewController = segue.destination as? CustomGattMqttViewController {
            viewController.peripheral = peripheral
        }
    }
}

extension DevicesViewController {

    @objc
    func reloadDataWithoutAnimation() {
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }

    func showLogin() {
        AWSMobileClient.sharedInstance().initialize { userState, error in

            // initialize error

            if let error = error {
                DispatchQueue.main.async {
                    Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                        .action(.default(NSLocalizedString("OK", comment: String())))
                        .show(on: self)
                }
                return
            }

            // process userState

            guard let navigationController = self.navigationController, let userState = userState else {
                return
            }

            switch userState {

            case .signedIn:
                self.attachPrincipalPolicy()

            case .signedOut:

                let signInUIOptions = SignInUIOptions(canCancel: false, logoImage: #imageLiteral(resourceName: "common_logo"), backgroundColor: UIColor(named: "teal_color"))
                AWSMobileClient.sharedInstance().showSignIn(navigationController: navigationController, signInUIOptions: signInUIOptions) { _, error in

                    // signin error

                    if let error = error {
                        DispatchQueue.main.async {
                            Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                                .action(.default(NSLocalizedString("OK", comment: String())))
                                .show(on: self)
                        }
                        return
                    }

                    self.attachPrincipalPolicy()
                }

            default:
                AWSMobileClient.sharedInstance().signOut()
            }
        }
    }

    #warning("attachPrincipalPolicy should NOT be done in the app, this is just for demo purposes. See getting started guide.")
    /**
     Attach the coginto identity to the AWS IoT policy.

     - Precondition: The AWS IoT policy must already have been created. Follow the get started guide if not.
     */
    func attachPrincipalPolicy() {

        // get the AWS Cognito Identity

        AWSMobileClient.sharedInstance().getIdentityId().continueWith { task -> Any? in

            if let error = task.error {
                DispatchQueue.main.async {
                    Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                        .action(.default(NSLocalizedString("OK", comment: String())))
                        .show(on: self)
                }
                return task
            }

            guard let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest(), let principal = task.result else {
                return task
            }

            // The AWS IoT Policy
            attachPrincipalPolicyRequest.policyName = AmazonConstants.AWS.iotPolicyName
            // The AWS Cognito Identity
            attachPrincipalPolicyRequest.principal = String(principal)

            AWSIoT.default().attachPrincipalPolicy(attachPrincipalPolicyRequest, completionHandler: { error in
                if let error = error {
                    DispatchQueue.main.async {
                        Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                            .action(.default(NSLocalizedString("OK", comment: String())))
                            .show(on: self)
                        return
                    }
                }
            })

            return task
        }
    }
}

// UITableView

extension DevicesViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.backgroundColor = .white
        if AmazonFreeRTOSManager.shared.peripherals.isEmpty {
            tableView.backgroundColor = .clear
        }
        return AmazonFreeRTOSManager.shared.peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell", for: indexPath)
        guard let peripheralCell = cell as? PeripheralCell else {
            return cell
        }
        let peripheral = Array(AmazonFreeRTOSManager.shared.peripherals.values)[indexPath.row]
        peripheralCell.labPeripheralName.text = peripheral.name
        // iOS use generated identifier, it will be different on other devices.
        peripheralCell.labPeripheralUUID.text = peripheral.identifier.uuidString
        if peripheral.state == .connected {
            peripheralCell.viewPeripheralStateIndicator.backgroundColor = UIColor(named: "seafoam_green_color")
        } else {
            peripheralCell.viewPeripheralStateIndicator.backgroundColor = UIColor.clear
        }
        return peripheralCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        let peripheral = Array(AmazonFreeRTOSManager.shared.peripherals.values)[indexPath.row]
        self.peripheral = peripheral
        if peripheral.state == .connected {
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
                .show(on: self)
        } else {
            AmazonFreeRTOSManager.shared.connectPeripheral(peripheral, reconnect: true)
        }
    }

    override func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let peripheral = Array(AmazonFreeRTOSManager.shared.peripherals.values)[indexPath.row]
        if peripheral.state == .connected {
            return true
        }
        return false
    }

    override func tableView(_: UITableView, titleForDeleteConfirmationButtonForRowAt _: IndexPath) -> String? {
        return NSLocalizedString("Disconnect", comment: String())
    }

    override func tableView(_: UITableView, commit _: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let peripheral = Array(AmazonFreeRTOSManager.shared.peripherals.values)[indexPath.row]
        AmazonFreeRTOSManager.shared.disconnectPeripheral(peripheral)
    }
}

extension DevicesViewController {

    @IBAction private func btnRescanPush(_: UIBarButtonItem) {
        AmazonFreeRTOSManager.shared.rescanForPeripherals()
        reloadDataWithoutAnimation()
    }

    @IBAction private func btnLogoutPush(_: UIBarButtonItem) {
        AWSMobileClient.sharedInstance().signOut()
        showLogin()
    }
}
