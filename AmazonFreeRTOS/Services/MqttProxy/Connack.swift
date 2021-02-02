/// Mqtt proxy message of Connack.
/*
 public struct Connack: Encborable {

    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    public var status: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: MqttMessageType.connack.rawValue, CborKey.status.rawValue: status]
    }
 }
 */

public struct Connack: Encodable {

    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    private var messageType: Int
    public var status: Int

    public init(status: Int) {
        messageType = MqttMessageType.connack.rawValue
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
        case status = "s" /// CborKey.status.rawValue
    }
}
