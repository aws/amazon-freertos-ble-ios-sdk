import Foundation

/// Generic mqtt proxy message.
struct MqttProxyMessage: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
}
