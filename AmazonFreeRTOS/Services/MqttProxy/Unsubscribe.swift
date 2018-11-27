import Foundation

/// Mqtt proxy message of Unsubscribe.
public struct Unsubscribe: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int
}
