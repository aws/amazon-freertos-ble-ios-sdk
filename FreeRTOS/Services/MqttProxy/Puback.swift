import Foundation

/// Mqtt proxy message of Puback.
struct Puback: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt message id.
    var msgID: Int
}
