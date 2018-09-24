import Foundation

struct Suback: Codable {
    let type: MqttMessageType
    let msgID, status: Int
}
