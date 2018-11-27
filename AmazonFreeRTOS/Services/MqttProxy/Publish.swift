import Foundation

/// Mqtt proxy message of Publish.
public struct Publish: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt topic.
    public var topic: String
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoS.
    public var qoS: Int
    /// Mqtt payload.
    public var payloadVal: String
}
