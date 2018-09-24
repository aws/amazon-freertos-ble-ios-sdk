import Foundation

struct Timeout: Codable {
    let type: MetadataMessageType
    var timeout: Int
}
