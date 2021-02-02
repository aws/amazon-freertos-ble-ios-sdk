/// Mqtt proxy message of Puback.
/*
 public struct Puback: Encborable {

 /// Mqtt message id.
 public var msgID: Int

 func toDictionary() -> NSDictionary {
     return [CborKey.type.rawValue: MqttMessageType.puback.rawValue, CborKey.msgID.rawValue: msgID]
 }
 }
 */

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
        case messageType = "w" /// CborKey.type.rawValue
        case msgID = "i" /// CborKey.msgID.rawValue
    }
}
