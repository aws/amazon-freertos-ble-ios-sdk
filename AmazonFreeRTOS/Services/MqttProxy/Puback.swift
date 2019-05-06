/// Mqtt proxy message of Puback.
public struct Puback: Encborable {

    /// Mqtt message id.
    public var msgID: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: MqttMessageType.puback.rawValue, CborKey.msgID.rawValue: msgID]
    }
}
