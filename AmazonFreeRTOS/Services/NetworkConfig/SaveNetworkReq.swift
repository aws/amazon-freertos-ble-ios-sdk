/// Save network request.
public struct SaveNetworkReq: Encodable {
    /// Mqtt message type
    private var messageType: Int
    /// Index of the network.
    public var index: Int
    /// Wifi ssid.
    public var ssid: String
    /// Wifi bssid (Mac address).
    public var bssid: String
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
    public init(index: Int, ssid: String, bssid: String, psk: String, security: NetworkSecurityType, connect: Bool) {
        messageType = NetworkMessageType.saveNetworkReq.rawValue
        self.index = index
        self.ssid = ssid
        self.bssid = bssid
        self.psk = psk
        self.security = security
        self.connect = connect
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
        case index = "g" /// CborKey.index.rawValue
        case ssid = "r" /// CborKey.ssid.rawValue
        case bssid = "b" /// CborKey.bssid.rawValue
        case psk = "m" /// CborKey.psk.rawValue
        case security = "q" /// CborKey.security.rawValue
        case connect = "y" /// CborKey.connect.rawValue
    }
}
