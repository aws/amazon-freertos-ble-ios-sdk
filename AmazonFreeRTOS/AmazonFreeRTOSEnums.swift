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
    case brokerEndpoint = "a"
    case bssid = "b"
    case cleanSession = "c"
    case clientID = "d"
    case connected = "e"
    case hidden = "f"
    case index = "g"
    case maxNetworks = "h"
    case msgID = "i"
    case newIndex = "j"
    case payloadVal = "k"
    case proxyState = "l"
    case psk = "m"
    case qoS = "n"
    case qoSs = "o"
    case rssi = "p"
    case security = "q"
    case ssid = "r"
    case status = "s"
    case timeout = "t"
    case topic = "u"
    case topics = "v"
    case type = "w"
}
