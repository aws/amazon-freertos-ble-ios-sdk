/// Mqtt proxy message of Suback.
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
        case messageType = "w" /// CborKey.type.rawValue
        case msgID = "i" /// CborKey.msgID.rawValue
        case status = "s" /// CborKey.status.rawValue
    }
}
