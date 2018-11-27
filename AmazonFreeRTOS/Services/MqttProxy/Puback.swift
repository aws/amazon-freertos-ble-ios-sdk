import Foundation

/// Mqtt proxy message of Puback.
public struct Puback: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt message id.
    public var msgID: Int
}
