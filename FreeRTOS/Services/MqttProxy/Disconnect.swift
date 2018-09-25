import Foundation

/// Mqtt proxy message of Disconnect.
struct Disconnect: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
}
