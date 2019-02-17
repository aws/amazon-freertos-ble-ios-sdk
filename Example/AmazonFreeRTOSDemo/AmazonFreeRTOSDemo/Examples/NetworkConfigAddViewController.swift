import Alertift
import AmazonFreeRTOS
import CoreBluetooth
import UIKit

class NetworkConfigAddViewController: UIViewController {

    @IBOutlet private var tfSSID: AmazonTextField!
    @IBOutlet private var tfPassword: AmazonTextField!
    @IBOutlet private var viewPassword: UIView!
    @IBOutlet private var segSecurity: UISegmentedControl!
    @IBOutlet private var lcScrollViewBottom: NSLayoutConstraint!

    var peripheral: CBPeripheral?
    var network: ListNetworkResp?

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let network = network {
            tfSSID.text = network.ssid
            tfSSID.isEnabled = false
            if network.security == .open {
                viewPassword.isHidden = true
            }
            segSecurity.selectedSegmentIndex = network.security.rawValue
            segSecurity.isUserInteractionEnabled = false
        }

        segSecurity.sendActions(for: .valueChanged)
    }

    func addNetwork(connect: Bool) {
        guard let peripheral = peripheral, let security = NetworkSecurityType(rawValue: segSecurity.selectedSegmentIndex) else {
            return
        }
        guard let ssid = tfSSID.text, !ssid.isEmpty else {
            Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: NSLocalizedString("Please enter a valid SSID.", comment: String()))
                .action(.default(NSLocalizedString("OK", comment: String())))
                .show(on: self)
            return
        }
        if security != .open, tfPassword.text?.isEmpty ?? true {
            Alertift.alert(title: NSLocalizedString("Error", comment: String()), message: NSLocalizedString("Please enter a valid password.", comment: String()))
                .action(.default(NSLocalizedString("OK", comment: String())))
                .show(on: self)
            return
        }
        AmazonFreeRTOSManager.shared.saveNetworkToPeripheral(peripheral, saveNetworkReq: SaveNetworkReq(index: network?.index ?? -1, ssid: ssid, bssid: network?.bssid ?? "000000000000", psk: tfPassword.text ?? String(), security: security, connect: connect))
        dismiss(animated: true)
    }
}

// Keyboard

extension NetworkConfigAddViewController {

    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        lcScrollViewBottom.constant = keyboardSize.height - view.safeAreaInsets.bottom
        UIView.performWithoutAnimation {
            view.layoutIfNeeded()
        }
    }

    @objc
    func keyboardWillHide(notification _: NSNotification) {
        lcScrollViewBottom.constant = 170.0
        UIView.performWithoutAnimation {
            view.layoutIfNeeded()
        }
    }
}

extension NetworkConfigAddViewController {

    @IBAction private func segSecurityValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tfPassword.text = nil
            viewPassword.isHidden = true
            return
        }
        viewPassword.isHidden = false
    }

    @IBAction private func btnSavePush(_: UIButton) {
        addNetwork(connect: false)
    }

    @IBAction private func btnConnectPush(_: UIButton) {
        addNetwork(connect: true)
    }
}
