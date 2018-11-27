import UIKit

extension UITableView {

    func enableTableView() {
        isUserInteractionEnabled = true
        alpha = 1.0
    }

    func disableTableView() {
        isUserInteractionEnabled = false
        alpha = 0.2
    }
}
