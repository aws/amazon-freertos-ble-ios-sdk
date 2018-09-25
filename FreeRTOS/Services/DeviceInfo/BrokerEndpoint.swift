import Foundation

/// Device info message of broker endpoint.
struct BrokerEndpoint: Codable {
    /// Device info message type.
    var type: DeviceInfoMessageType
    /// Mqtt broker endpoint on the FreeRTOS device.
    var brokerEndpoint: String
}
