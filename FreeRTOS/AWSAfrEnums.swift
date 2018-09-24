import Foundation

/// Metadata Message Types.
enum MetadataMessageType: Int, Codable {
    case topic = 0
    case mtu = 1
    case brokerEndpoint = 2
    case timeout = 3
}

/// Mqtt Message Types. Reference: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718021
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

/// Topic Types
enum TopicType: Int, Codable {
    case string = 0
    case characteristic = 1
    case object = 2
}

/// Payload Types
enum PayloadType: Int, Codable {
    case string = 0
    case characteristic = 1
    case object = 2
}

/// Network Security Types
enum NetworkSecurityType: Int, Codable {
    case open = 0
    case wep = 1
    case wpa = 2
    case wpa2 = 3
    case notSupported = 4
}

/// Network Statuses
enum NetworkStatus: Int, Codable {
    case success = 0
    case failure = 1
    case timeout = 2
    case notSupported = 3
}
