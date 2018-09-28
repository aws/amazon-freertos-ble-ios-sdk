import UIKit

extension UIViewController {

    @IBAction private func btnBackPush(_: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction private func btnClosePush(_: UIBarButtonItem) {
        dismiss(animated: true)
    }

    // Dismiss keyboard on done
    @objc
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// UINavigationControllerDelegate

extension UIViewController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated _: Bool) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = viewController != navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}
