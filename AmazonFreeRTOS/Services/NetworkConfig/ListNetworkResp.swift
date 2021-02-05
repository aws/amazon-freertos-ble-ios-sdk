/// List network response.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct ListNetworkResp: Decodable {
    /// Index of the network. < 0 for scaned networks.
    public var index: Int
    /// List operation status.
    public var status: NetworkOpStatus
    /// Wifi ssid.
    public var ssid: String
    /// Wifi bssid (Mac address).
    public var bssid: Data
    /// Wifi rssi (Signal strenth).
    public var rssi: Int
    /// Wifi security type.
    public var security: NetworkSecurityType
    /// Wifi is hidden or not.
    public var hidden: Bool
    /// Wifi is connected or not.
    public var connected: Bool

    private enum CodingKeys: String, CodingKey {
        case index = "g"
        case status = "s"
        case ssid = "r"
        case bssid = "b"
        case rssi = "p"
        case security = "q"
        case hidden = "f"
        case connected = "e"
    }
}
