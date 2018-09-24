import Foundation

struct Disconnack: Codable {
    let type: MqttMessageType
    let status: Int
}
