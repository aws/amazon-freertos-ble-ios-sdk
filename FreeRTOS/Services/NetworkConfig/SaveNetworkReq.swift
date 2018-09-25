import Foundation

/// Save network request.
struct SaveNetworkReq: Codable {
    /// Index of the network.
    var index: Int
    /// Wifi ssid.
    var ssid: String
    /// Wifi bssid (Mac address).
    var bssid: String
    /// Wifi password.
    var psk: String
    /// Wifi security type.
    var security: NetworkSecurityType
}
