import Foundation

/// Mqtt proxy message of Connack.
struct Connack: Codable {
    /// Mqtt message type.
    var type: MqttMessageType
    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    var status: Int
}
