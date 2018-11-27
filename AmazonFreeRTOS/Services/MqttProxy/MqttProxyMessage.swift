import Foundation

/// Generic mqtt proxy message.
public struct MqttProxyMessage: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
}
