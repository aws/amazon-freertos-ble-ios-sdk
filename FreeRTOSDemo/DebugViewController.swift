import UIKit

class DebugViewController: UIViewController {

    @IBOutlet private var txtDebugMessages: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtDebugMessages.text = AWSAfrManager.shared.debugMessages
        NotificationCenter.default.addObserver(self, selector: #selector(debugPrint(_:)), name: .debugPrint, object: nil)
    }

    @objc
    func debugPrint(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.txtDebugMessages.text += notification.userInfo?["debugMessage"] as? String ?? String()
            self.txtDebugMessages.scrollToBottom()
        }
    }
}
