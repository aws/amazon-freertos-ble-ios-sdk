import Alertift
import AWSAuthCore
import AWSAuthUI
import AWSIoT
import CoreBluetooth
import UIKit

class DevicesViewController: UITableViewController {

    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self

        // Observe peripherals

        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverPeripheral), name: .didDiscoverPeripheral, object: nil)

        // Rescan peripherals

        refreshControl?.addTarget(self, action: #selector(rescanPeripherals), for: .valueChanged)
        refreshControl?.beginRefreshing()

        // Check user login

        guard let navigationController = navigationController, !AWSSignInManager.sharedInstance().isLoggedIn else {
            attachPrincipalPolicy()
            return
        }

        AWSAuthUIViewController.presentViewController(with: navigationController, configuration: nil) { _, error in
            if let error = error {
                Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: error.localizedDescription)
                    .action(.default(NSLocalizedString("OK", comment: String())))
                    .show()
                return
            }
            self.attachPrincipalPolicy()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // Segue

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "toMqttViewController", let viewController: MqttViewController = segue.destination as? MqttViewController {
            viewController.peripheral = peripheral
        } else if segue.identifier == "toNetworkViewController", let viewController: NetworkViewController = segue.destination as? NetworkViewController {
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

    func attachPrincipalPolicy() {
        guard let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest() else {
            return
        }
        attachPrincipalPolicyRequest.policyName = "freerots"
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

    // using Manager.shared.bleItems directly is not safe, will change later.

    override func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.backgroundColor = .white
        if AWSAfrManager.shared.peripherals.isEmpty {
            tableView.backgroundColor = .clear
        }
        return AWSAfrManager.shared.peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DevicesCell", for: indexPath)
        guard let devicesCell = cell as? DevicesCell else {
            return cell
        }
        let device = Array(AWSAfrManager.shared.peripherals.values)[indexPath.row]
        devicesCell.labPeripheralName.text = device.name
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
            .action(.default(NSLocalizedString("MQTT Proxy", comment: String()))) { _, _ in
                self.performSegue(withIdentifier: "toMqttViewController", sender: self)
                return
            }
            .action(.default(NSLocalizedString("Network Setup", comment: String()))) { _, _ in
                self.performSegue(withIdentifier: "toNetworkViewController", sender: self)
                return
            }
            .action(.default(NSLocalizedString("Custom GATT MQTT", comment: String()))) { _, _ in
                self.performSegue(withIdentifier: "toCustomGattMqttViewController", sender: self)
                return
            }
            .action(.cancel(NSLocalizedString("Cancel", comment: String())))
            .show()
    }
}
