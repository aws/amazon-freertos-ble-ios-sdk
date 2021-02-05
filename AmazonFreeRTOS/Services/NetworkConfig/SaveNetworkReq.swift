/// Save network request.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct SaveNetworkReq: Encodable {
    /// Mqtt message type
    private var messageType: Int
    /// Index of the network.
    public var index: Int
    /// Wifi ssid.
    public var ssid: String
    /// Wifi bssid (Mac address).
    public var bssid: Data
    /// Wifi password. Saved network ignore this value.
    public var psk: String
    /// Wifi security type.
    public var security: NetworkSecurityType
    /// Connect immediately or just save for later.
    public var connect: Bool

    /// SaveNetworkReq is used to save wifi network.
    ///
    /// - Parameters:
    ///     - index: Index of the network.
    ///     - ssid: Wifi ssid.
    ///     - bssid: Wifi bssid (Mac address).
    ///     - psk: Wifi password. Saved network ignore this value.
    ///     - security: Wifi security type.
    ///     - connect: Connect immediately or just save for later.
    /// - Returns: A new SaveNetworkReq.
    public init(index: Int, ssid: String, bssid: Data, psk: String, security: NetworkSecurityType, connect: Bool) {
        messageType = NetworkMessageType.saveNetworkReq.rawValue
        self.index = index
        self.ssid = ssid
        self.bssid = bssid
        self.psk = psk
        self.security = security
        self.connect = connect
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w"
        case index = "g"
        case ssid = "r"
        case bssid = "b"
        case psk = "m"
        case security = "q"
        case connect = "y"
    }
}
