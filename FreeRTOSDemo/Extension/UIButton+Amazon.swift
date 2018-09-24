import UIKit

extension UIButton {

    func enableButton() {
        isEnabled = true
        alpha = 1.0
    }

    func disableButton() {
        isEnabled = false
        alpha = 0.8
    }
}
