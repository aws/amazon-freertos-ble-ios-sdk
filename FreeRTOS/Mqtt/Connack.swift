import Foundation

struct Connack: Codable {
    let type: MqttMessageType
    let status: Int
}
