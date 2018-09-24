import Foundation

struct Unsuback: Codable {
    let type: MqttMessageType
    let msgID: Int
}
