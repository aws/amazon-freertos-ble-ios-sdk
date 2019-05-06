/// Mqtt proxy message of Connack.
public struct Connack: Encborable {

    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    public var status: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: MqttMessageType.connack.rawValue, CborKey.status.rawValue: status]
    }
}
