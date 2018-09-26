import Foundation

/// List network response.
struct ListNetworkResp: Codable {
    /// Index of the network. < 0 for scaned networks.
    var index: Int
    /// List operation status.
    var status: NetworkOpStatus
    /// Wifi ssid.
    var ssid: String
    /// Wifi bssid (Mac address).
    var bssid: String
    /// Wifi rssi (Signal strenth).
    var rssi: Int
    /// Wifi security type.
    var security: NetworkSecurityType
    /// Wifi is hidden or not.
    var hidden: Bool
    /// Wifi is connected or not.
    var connected: Bool
}
