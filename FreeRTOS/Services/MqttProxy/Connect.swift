import Foundation

/// Mqtt proxy message of Connect.
struct Connect: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt client id.
    var clientID: String
    /// Mqtt broker endpoint.
    var brokerEndpoint: String
    /// Mqtt clean session.
    var cleanSession: Bool
}
