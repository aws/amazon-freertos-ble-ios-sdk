import UIKit

extension UITextView {

    func scrollToBottom() {
        guard !text.isEmpty else {
            return
        }
        scrollRangeToVisible(NSRange(location: text.count - 1, length: 1))
    }
}
