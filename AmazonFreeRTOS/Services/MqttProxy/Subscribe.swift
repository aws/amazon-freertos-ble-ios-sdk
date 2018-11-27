import Foundation

/// Mqtt proxy message of Subscribe.
public struct Subscribe: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoSs.
    public var qoSs: [Int]
}
