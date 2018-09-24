import Foundation

struct Publish: Codable {
    let type: MqttMessageType
    let topicID, msgID: Int
    let qoS: Int
    let payloadType: PayloadType
    let payloadVal: String
}
