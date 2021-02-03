/// List network response.
public struct ListNetworkResp: Decodable {
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

    private enum CodingKeys: String, CodingKey {
        case index = "g" /// CborKey.index.rawValue
        case status = "s" /// CborKey.status.rawValue
        case ssid = "r" /// CborKey.ssid.rawValue
        case bssid = "b" /// CborKey.bssid.rawValue
        case rssi = "p" /// CborKey.rssi.rawValue
        case security = "q" /// CborKey.security.rawValue
        case hidden = "f" /// CborKey.hidden.rawValue
        case connected = "e" /// CborKey.connected.rawValue
    }
}
