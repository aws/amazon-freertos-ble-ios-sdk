import Foundation

struct Puback: Codable {
    let type: MqttMessageType
    let msgID: Int
}
