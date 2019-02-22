/// Mqtt proxy message of Suback.
public struct Suback: Encborable {

    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt message id.
    public var msgID: Int
    /// Suback status. (Use subscribe Qos on iOS).
    public var status: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: type.rawValue, CborKey.msgID.rawValue: msgID, CborKey.status.rawValue: status]
    }
}
