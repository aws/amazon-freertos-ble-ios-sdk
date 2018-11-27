import Foundation

/// Mqtt proxy message of Connack.
public struct Connack: Codable {
    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    public var status: Int
}
