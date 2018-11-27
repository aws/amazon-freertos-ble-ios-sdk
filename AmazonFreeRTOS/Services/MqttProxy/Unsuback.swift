import Foundation

/// Mqtt proxy message of Unsuback.
public struct Unsuback: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt message id.
    public var msgID: Int
}
