import Foundation

struct Topic: Codable {
    let type: MetadataMessageType
    var topicID: Int
    var topicValue: String
}
