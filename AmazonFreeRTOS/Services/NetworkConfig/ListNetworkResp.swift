import Foundation

/// List network response.
public struct ListNetworkResp: Codable {
    /// Index of the network. < 0 for scaned networks.
    public var index: Int
    /// List operation status.
    public var status: NetworkOpStatus
    /// Wifi ssid.
    public var ssid: String
    /// Wifi bssid (Mac address).
    public var bssid: String
    /// Wifi rssi (Signal strenth).
    public var rssi: Int
    /// Wifi security type.
    public var security: NetworkSecurityType
    /// Wifi is hidden or not.
    public var hidden: Bool
    /// Wifi is connected or not.
    public var connected: Bool
}
