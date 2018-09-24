import Foundation

extension Array {

    /// Helper - safe array access
    func object(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
