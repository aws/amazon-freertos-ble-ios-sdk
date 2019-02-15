import AmazonFreeRTOS
import UIKit

class DebugViewController: UIViewController {

    @IBOutlet private var swAutoScroll: UISwitch!
    @IBOutlet private var tvDebugMessages: UITextView!

    var refreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true

        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: UIApplication.willEnterForegroundNotification, object: nil)

        swAutoScroll.setOn(AmazonContext.shared.debugAutoScroll, animated: false)
        swAutoScroll.sendActions(for: .valueChanged)
        tvDebugMessages.text = AmazonFreeRTOSManager.shared.debugMessages
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
}

// Timer

extension DebugViewController {

    @objc
    func startTimer() {
        refreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDebugMessages), userInfo: nil, repeats: true)
        refreshTimer?.fire()
    }

    @objc
    func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    @objc
    func updateDebugMessages() {
        tvDebugMessages.text = AmazonFreeRTOSManager.shared.debugMessages
        if swAutoScroll.isOn {
            tvDebugMessages.scrollToBottom()
        }
    }
}

extension DebugViewController {

    @IBAction private func btnClearPush(_: UIBarButtonItem) {
        AmazonFreeRTOSManager.shared.debugMessages = String()
        tvDebugMessages.text = AmazonFreeRTOSManager.shared.debugMessages
    }

    @IBAction private func swAutoScrollValueChanged(_ sender: UISwitch) {
        AmazonContext.shared.debugAutoScroll = sender.isOn
        if sender.isOn {
            tvDebugMessages.scrollToBottom()
        }
    }
}
