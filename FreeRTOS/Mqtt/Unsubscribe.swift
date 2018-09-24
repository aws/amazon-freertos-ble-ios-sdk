import Foundation

struct Unsubscribe: Codable {
    let type: MqttMessageType
    let topicID, msgID: Int
}
