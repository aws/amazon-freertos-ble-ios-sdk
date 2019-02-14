import Foundation

class AmazonContext: NSObject {

    static let shared = AmazonContext()

    var debugMessages = String()
    var debugAutoScroll = true

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(debugMessage(_:)), name: .afrDebugMessage, object: nil)
    }

    @objc
    func debugMessage(_ notification: NSNotification) {
        guard let debugMessage = notification.userInfo?["debugMessage"] as? String else {
            return
        }
        debugMessages += "[\(Date())] \(debugMessage)\n\n"
    }
}
