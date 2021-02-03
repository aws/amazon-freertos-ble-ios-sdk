/// Mqtt proxy message of Unsuback.
public struct Unsuback: Encodable {

    /// Mqtt message type
    private var messageType: Int
    /// Mqtt message id.
    public var msgID: Int

    public init(msgID: Int) {
        messageType = MqttMessageType.unsuback.rawValue
        self.msgID = msgID
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
        case msgID = "i" /// CborKey.msgID.rawValue
    }
}
