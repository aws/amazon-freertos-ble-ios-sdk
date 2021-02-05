/// Mqtt proxy message of Puback.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Puback: Encodable {

    /// Mqtt message type
    private var messageType: Int
    /// Mqtt message id.
    public var msgID: Int

    public init(msgID: Int) {
        messageType = MqttMessageType.puback.rawValue
        self.msgID = msgID
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w"
        case msgID = "i"
    }
}
