import Foundation

/// Mqtt proxy message of Connect.
public struct Connect: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt client id.
    public var clientID: String
    /// Mqtt broker endpoint.
    public var brokerEndpoint: String
    /// Mqtt clean session.
    public var cleanSession: Bool
}
