import Foundation

/// Mqtt proxy message of Disconnect.
public struct Disconnect: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
}
