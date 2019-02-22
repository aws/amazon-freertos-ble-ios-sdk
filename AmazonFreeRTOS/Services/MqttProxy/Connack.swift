/// Mqtt proxy message of Connack.
public struct Connack: Encborable {

    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    public var status: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: type.rawValue, CborKey.status.rawValue: status]
    }
}
