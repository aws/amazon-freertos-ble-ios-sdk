/// Mqtt proxy message of Suback.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Suback: Encodable {

    /// Mqtt message type
    private var messageType: Int
    /// Mqtt message id.
    public var msgID: Int
    /// Suback status. Use subscribe Qos on iOS.
    public var status: Int

    public init(msgID: Int, status: Int) {
        messageType = MqttMessageType.suback.rawValue
        self.msgID = msgID
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w"
        case msgID = "i"
        case status = "s"
    }
}
