/// Mqtt proxy message of Connack.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Connack: Encodable {

    /// Mqtt connection status. Reference: https://github.com/aws/aws-sdk-ios/blob/master/AWSIoT/AWSIoTMQTTTypes.h#L20
    private var messageType: Int
    public var status: Int

    public init(status: Int) {
        messageType = MqttMessageType.connack.rawValue
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w"
        case status = "s"
    }
}
