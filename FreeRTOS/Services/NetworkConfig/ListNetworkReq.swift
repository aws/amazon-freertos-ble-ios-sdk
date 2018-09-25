import Foundation

/// List network request.
struct ListNetworkReq: Codable {
    /// Max number of networks to scan.
    var maxNetworks: Int
    /// Time to scan in seconds.
    var timeout: Int
}
