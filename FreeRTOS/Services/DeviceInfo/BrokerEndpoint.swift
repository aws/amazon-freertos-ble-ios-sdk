import Foundation

/// Device info message of broker endpoint.
struct BrokerEndpoint: Codable {
    /// Mqtt broker endpoint on the FreeRTOS device.
    var brokerEndpoint: String
}
