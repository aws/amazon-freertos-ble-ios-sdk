import Foundation

struct BrokerEndpoint: Codable {
    let type: MetadataMessageType
    var brokerEndpoint: String
}
