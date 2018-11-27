import Foundation

/// Device info message of broker endpoint.
public struct BrokerEndpoint: Codable {
    /// Mqtt broker endpoint on the FreeRTOS device.
    public var brokerEndpoint: String
}
