import CoreBluetooth
import UIKit

class MqttViewController: UITableViewController {

    var peripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let peripheral = peripheral else {
            return
        }

        addObservers()

        title = peripheral.name
        AWSAfrManager.shared.connectPeripheral(peripheral)
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

extension MqttViewController {

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDiscoverCharacteristics(_:)), name: .didDiscoverCharacteristics, object: nil)
    }

    @objc
    func didDiscoverCharacteristics(_ notification: NSNotification) {
        guard let peripheral = peripheral, notification.userInfo?["service"] as? CBUUID == AWSAfrGattService.Mqtt else {
            return
        }
        AWSAfrManager.shared.startMqttOfPeripheral(peripheral)
        tableView.reloadData()
    }
}

// UITableView

extension MqttViewController {

    override func numberOfSections(in _: UITableView) -> Int {
        return peripheral?.services?.count ?? 0
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheral?.services?[section].characteristics?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell")
        guard let sectionHeaderCell = cell as? SectionHeaderCell else {
            return nil
        }
        sectionHeaderCell.labSectionTitle.text = String.localizedStringWithFormat(NSLocalizedString("Service %d: %@", comment: String()), section, peripheral?.services?[section].uuid.uuidString ?? String())
        sectionHeaderCell.labSectionEmpty.text = NSLocalizedString("No characteristics", comment: String())
        return sectionHeaderCell.contentView
    }

    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if peripheral?.services?[section].characteristics?.isEmpty ?? true {
            return 112.0
        }
        return 52.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacteristicCell", for: indexPath)
        guard let characteristicCell = cell as? CharacteristicCell else {
            return cell
        }
        let characteristic = peripheral?.services?[indexPath.section].characteristics?[indexPath.row]
        characteristicCell.labCharacteristicUUID.text = characteristic?.uuid.uuidString
        characteristicCell.labCharacteristicProperties.text = characteristic?.properties.propertiesString()
        return characteristicCell
    }
}

extension MqttViewController {

    @IBAction private func btnDebugPush(_: UIBarButtonItem) {
        performSegue(withIdentifier: "toDebugViewController", sender: self)
    }
}
