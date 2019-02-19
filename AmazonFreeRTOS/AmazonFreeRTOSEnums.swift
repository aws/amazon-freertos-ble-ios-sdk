import Foundation

/// Mqtt proxy state.
public enum MqttProxyState: Int {
    /// Mqtt proxy off.
    case off = 0
    /// Mqtt proxy on.
    case on = 1
}

/// Mqtt message types. Reference: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718021
public enum MqttMessageType: Int {
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
    /// Not supported by AWS IoT.
    case pingreq = 12
    /// Not supported by AWS IoT.
    case pingresp = 13
    /// Disconnnect.
    case disconnnect = 14
}

/// Network security types.
public enum NetworkSecurityType: Int {
    /// Open.
    case open = 0
    /// Wep.
    case wep = 1
    /// Wpa.
    case wpa = 2
    /// Wpa 2.
    case wpa2 = 3
    /// Not Supported.
    case notSupported = 4
}

/// Network statuses.
public enum NetworkOpStatus: Int {
    /// Success.
    case success = 0
    /// Failure.
    case failure = 1
    /// Timeout.
    case timeout = 2
    /// Not Supported.
    case notSupported = 3
}

/// Keys for cbor
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
