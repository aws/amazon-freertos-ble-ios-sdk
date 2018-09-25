import Foundation

/// Mqtt proxy message of Suback.
struct Suback: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt message id.
    var msgID: Int
    /// Suback status. (Use subscribe Qos on iOS).
    var status: Int
}
