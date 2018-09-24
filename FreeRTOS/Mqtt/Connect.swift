import Foundation

struct Connect: Codable {
    let type: MqttMessageType
    let clientID, brokerEndpoint, userName: String
    let cleanSession: Bool
}
