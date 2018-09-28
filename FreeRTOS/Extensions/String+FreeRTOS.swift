import Foundation

extension String {

    /// Helper - base64 encode
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    /// Helper - base64 decode
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
