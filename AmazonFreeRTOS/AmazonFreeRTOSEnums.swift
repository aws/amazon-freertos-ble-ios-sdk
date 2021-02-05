/// Mqtt message types. Reference: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718021
public enum MqttMessageType: Int, Codable {
    /// Connect.
    case connect = 1
    /// Connack.
    case connack = 2
    /// Publish.
    case publish = 3
    /// Puback.
    case puback = 4
    /// Not supported by AWS IoT.
    case pubrec = 5
    /// Not supported by AWS IoT.
    case pubrel = 6
    /// Not supported by AWS IoT.
    case pubcomp = 7
    /// Subscribe.
    case subscribe = 8
    /// Suback.
    case suback = 9
    /// Unsubscribe.
    case unsubscribe = 10
    /// Unsuback.
    case unsuback = 11
    /// Pingreq.
    case pingreq = 12
    /// Pingresp.
    case pingresp = 13
    /// Disconnnect.
    case disconnnect = 14
}

/// Network message type.
public enum NetworkMessageType: Int, Codable {
    /// ListNetworkReq.
    case listNetworkReq = 1
    /// ListNetworkResp.
    case listNetworkResp = 2
    /// SaveNetworkReq.
    case saveNetworkReq = 3
    /// SaveNetworkResp.
    case saveNetworkResp = 4
    /// EditNetworkReq.
    case editNetworkReq = 5
    /// EditNetworkResp.
    case editNetworkResp = 6
    /// DeleteNetworkReq.
    case deleteNetworkReq = 7
    /// DeleteNetworkResp.
    case deleteNetworkResp = 8
}

/// Network security types.
public enum NetworkSecurityType: Int, Codable {
    /// Open.
    case open = 0
    /// Wep.
    case wep = 1
    /// Wpa.
    case wpa = 2
    /// Wpa 2.
    case wpa2 = 3
    /// Wpa 2 Enterprise.
    case wpa2Ent = 4
    /// Not Supported.
    case notSupported = 5
}

/// Network statuses.
public enum NetworkOpStatus: Int, Codable {
    /// Success.
    case success = 0
    /// Failure.
    case failure = 1
    /// Timeout.
    case timeout = 2
    /// Not Supported.
    case notSupported = 3
}

/// Keys for cbor.
public enum CborKey: String {
    /// brokerEndpoint.
    case brokerEndpoint = "a"
    /// bssid.
    case bssid = "b"
    /// cleanSession.
    case cleanSession = "c"
    /// clientID.
    case clientID = "d"
    /// connected.
    case connected = "e"
    /// hidden.
    case hidden = "f"
    /// index.
    case index = "g"
    /// maxNetworks.
    case maxNetworks = "h"
    /// msgID.
    case msgID = "i"
    /// newIndex.
    case newIndex = "j"
    /// payload.
    case payload = "k"
    /// proxyState.
    case proxyState = "l"
    /// psk.
    case psk = "m"
    /// qoS.
    case qoS = "n"
    /// qoSs.
    case qoSs = "o"
    /// rssi.
    case rssi = "p"
    /// security.
    case security = "q"
    /// ssid.
    case ssid = "r"
    /// status.
    case status = "s"
    /// timeout.
    case timeout = "t"
    /// topic.
    case topic = "u"
    /// topics.
    case topics = "v"
    /// type.
    case type = "w"
    /// connect.
    case connect = "y"
}
