import Foundation

/// Mqtt proxy message of Subscribe.
struct Subscribe: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt topic.
    var topic: String
    /// Mqtt message id.
    var msgID: Int
    /// Mqtt QoS.
    var qoS: Int
}
