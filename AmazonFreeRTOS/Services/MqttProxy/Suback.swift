import Foundation

/// Mqtt proxy message of Suback.
public struct Suback: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt message id.
    public var msgID: Int
    /// Suback status. (Use subscribe Qos on iOS).
    public var status: Int
}
