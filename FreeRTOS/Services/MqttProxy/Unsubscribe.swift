import Foundation

/// Mqtt proxy message of Unsubscribe.
struct Unsubscribe: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt topic.
    var topic: String
    /// Mqtt message id.
    var msgID: Int
}
