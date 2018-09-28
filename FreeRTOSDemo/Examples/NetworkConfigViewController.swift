import Alertift
import CoreBluetooth
import UIKit

/**
 Example 2: Network Config

 This example showcases how to use the network config service to configure the wifi network on the Amazon FreeRTOS device.
 */
class NetworkConfigViewController: UITableViewController {

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
        refreshControl?.addTarget(self, action: #selector(didOpNetwork), for: .valueChanged)
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

extension NetworkConfigViewController {

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverCharacteristics(_:)), name: .afrPeripheralDidDiscoverCharacteristics, object: nil)

        // ListNetwork returned one network

        NotificationCenter.default.addObserver(self, selector: #selector(didListNetwork), name: .afrDidListNetwork, object: nil)

        // Refresh list on network operations

        NotificationCenter.default.addObserver(self, selector: #selector(didOpNetwork), name: .afrDidSaveNetwork, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didOpNetwork), name: .afrDidEditNetwork, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didOpNetwork), name: .afrDidDeleteNetwork, object: nil)
    }

    @objc
    func didDiscoverCharacteristics(_ notification: NSNotification) {
        guard notification.userInfo?["service"] as? CBUUID == AWSAfrGattService.NetworkConfig else {
            return
        }

        // NetworkConfig service has been discovered.

        listNetworkOfPeripheral()
    }

    @objc
    func didListNetwork() {
        tableView.reloadData()
    }

    @objc
    func didOpNetwork() {
        refreshControl?.endRefreshing()
        tableView.enableTableView()

        listNetworkOfPeripheral()
    }

    // listNetworkOfPeripheral: scan max of 50 networks an scan for 3s

    func listNetworkOfPeripheral() {
        guard let peripheral = peripheral else {
            return
        }
        AWSAfrManager.shared.listNetworkOfPeripheral(peripheral, listNetworkReq: ListNetworkReq(maxNetworks: 50, timeout: 3))
        tableView.reloadData()
    }
}

// UITableView

extension NetworkConfigViewController {

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let peripheral = peripheral else {
            return 0
        }
        return AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[section].count ?? 0
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {

        case 0:
            return NSLocalizedString("Saved Networks", comment: String())

        case 1:
            return NSLocalizedString("Scanned Networks", comment: String())

        default:
            return nil
        }
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell")
        guard let sectionHeaderCell = cell as? SectionHeaderCell else {
            return nil
        }

        switch section {

        case 0:
            sectionHeaderCell.labSectionTitle.text = NSLocalizedString("Saved Networks", comment: String())
            sectionHeaderCell.labSectionEmpty.text = NSLocalizedString("No saved networks", comment: String())
            return sectionHeaderCell.contentView

        case 1:
            sectionHeaderCell.labSectionTitle.text = NSLocalizedString("Scanned Networks", comment: String())
            sectionHeaderCell.labSectionEmpty.text = NSLocalizedString("No scanned networks", comment: String())
            return sectionHeaderCell.contentView

        default:
            return sectionHeaderCell.contentView
        }
    }

    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let peripheral = peripheral else {
            return 112.0
        }
        if AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[section].isEmpty ?? true {
            return 112.0
        }
        return 52.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
        guard let networkCell = cell as? NetworkCell, let peripheral = peripheral, let network = AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[indexPath.section][indexPath.row] else {
            return cell
        }
        networkCell.labWifiSSID.text = network.ssid
        networkCell.labWifiSSID.textColor = network.connected ? UIColor(named: "seafoam_green_color") : UIColor(named: "teal_color")
        networkCell.labWifiSecurity.text = String(describing: network.security)
        networkCell.labWifiRSSI.text = String(network.rssi)
        networkCell.labWifiBSSID.text = network.bssid
        return networkCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let peripheral = peripheral, let network = AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[indexPath.section][indexPath.row] else {
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 || network.security == .open {

            // Its saved network or network security is open

            tableView.disableTableView()
            AWSAfrManager.shared.saveNetworkToPeripheral(peripheral, saveNetworkReq: SaveNetworkReq(index: network.index, ssid: network.ssid, bssid: network.bssid, psk: String(), security: network.security))

        } else if network.security == .notSupported {

            // Network not supported

            Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: NSLocalizedString("Network security type not supported.", comment: String()))
                .action(.default(NSLocalizedString("OK", comment: String())))
                .show()
        } else {

            // Network has security

            Alertift.alert(title: NSLocalizedString("Wi-Fi Password", comment: String()), message: NSLocalizedString("Please enter the password for this network.", comment: String()))
                .textField { textField in
                    textField.placeholder = NSLocalizedString("Password", comment: String())
                    textField.isSecureTextEntry = true
                }
                .action(.cancel(NSLocalizedString("Cancel", comment: String())))
                .action(.default(NSLocalizedString("Save", comment: String()))) { _, _, textFields in

                    tableView.disableTableView()
                    AWSAfrManager.shared.saveNetworkToPeripheral(peripheral, saveNetworkReq: SaveNetworkReq(index: network.index, ssid: network.ssid, bssid: network.bssid, psk: textFields?.first?.text ?? String(), security: network.security))
                }
                .show()
        }
    }

    override func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }

    override func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_: UITableView, commit _: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let peripheral = peripheral, let network = AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[indexPath.section][indexPath.row] else {
            return
        }

        // Edit network

        tableView.disableTableView()
        AWSAfrManager.shared.deleteNetworkFromPeripheral(peripheral, deleteNetworkReq: DeleteNetworkReq(index: network.index))
    }

    override func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let peripheral = peripheral, let sourceNetwork = AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[sourceIndexPath.section][sourceIndexPath.row], let destinationNetwork = AWSAfrManager.shared.networks[peripheral.identifier.uuidString]?[destinationIndexPath.section][destinationIndexPath.row] else {
            return
        }

        // Delete network

        tableView.disableTableView()
        AWSAfrManager.shared.editNetworkOfPeripheral(peripheral, editNetworkReq: EditNetworkReq(index: sourceNetwork.index, newIndex: destinationNetwork.index))
    }

//    override func tableView(_: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        if sourceIndexPath.section != proposedDestinationIndexPath.section {
//            return sourceIndexPath
//        }
//        return proposedDestinationIndexPath
//    }
}

extension NetworkConfigViewController {

    @IBAction private func btnDebugPush(_: UIBarButtonItem) {
        performSegue(withIdentifier: "toDebugViewController", sender: self)
    }

    @IBAction private func btnEditPush(_: UIButton) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
}
