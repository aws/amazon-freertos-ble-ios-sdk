import UIKit

class DebugViewController: UIViewController {

    @IBOutlet private var swAutoScroll: UISwitch!
    @IBOutlet private var tvDebugMessages: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        NotificationCenter.default.addObserver(self, selector: #selector(debugMessage(_:)), name: .afrDebugMessage, object: nil)
        swAutoScroll.setOn(AmazonContext.shared.debugAutoScroll, animated: false)
        swAutoScroll.sendActions(for: .valueChanged)
        tvDebugMessages.text = AmazonContext.shared.debugMessages
    }
}

// Observer

extension DebugViewController {

    @objc
    func debugMessage(_: NSNotification) {
        DispatchQueue.main.async {
            self.tvDebugMessages.text = AmazonContext.shared.debugMessages
            if self.swAutoScroll.isOn {
                self.tvDebugMessages.scrollToBottom()
            }
        }
    }
}

extension DebugViewController {

    @IBAction private func swAutoScrollValueChanged(_ sender: UISwitch) {
        AmazonContext.shared.debugAutoScroll = sender.isOn
        if sender.isOn {
            tvDebugMessages.scrollToBottom()
        }
    }
}
