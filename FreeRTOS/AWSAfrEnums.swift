import Foundation

/// Device info message type.
enum DeviceInfoMessageType: Int, Codable {
    case mtu = 0
    case brokerEndpoint = 1
}

/// Mqtt proxy state.
enum MqttProxyState: Int, Codable {
    case off = 0
    case on = 1
}

/// Mqtt message types. Reference: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718021
enum MqttMessageType: Int, Codable {
    case connect = 1
    case connack = 2
    case publish = 3
    case puback = 4
    /// Not supported by AWS IoT.
    case pubrec = 5
    /// Not supported by AWS IoT.
    case pubrel = 6
    /// Not supported by AWS IoT.
    case pubcomp = 7
    case subscribe = 8
    case suback = 9
    case unsubscribe = 10
    case unsuback = 11
    /// Not supported by AWS IoT.
    case pingreq = 12
    /// Not supported by AWS IoT.
    case pingresp = 13
    case disconnnect = 14
}

/// Network security types.
enum NetworkSecurityType: Int, Codable {
    case open = 0
    case wep = 1
    case wpa = 2
    case wpa2 = 3
    case notSupported = 4
}

/// Network statuses.
enum NetworkOpStatus: Int, Codable {
    case success = 0
    case failure = 1
    case timeout = 2
    case notSupported = 3
}
