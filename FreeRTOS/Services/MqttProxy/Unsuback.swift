import Foundation

/// Mqtt proxy message of Unsuback.
struct Unsuback: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt message id.
    var msgID: Int
}
