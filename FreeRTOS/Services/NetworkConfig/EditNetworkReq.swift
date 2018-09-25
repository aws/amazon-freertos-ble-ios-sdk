import Foundation

/// Edit network request.
struct EditNetworkReq: Codable {
    /// Old index of the saved network.
    var index: Int
    /// New index of the saved network.
    var newIndex: Int
}
