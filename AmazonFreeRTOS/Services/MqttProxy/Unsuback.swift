/// Mqtt proxy message of Unsuback.
public struct Unsuback: Encborable {

    /// Mqtt message id.
    public var msgID: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: MqttMessageType.unsuback.rawValue, CborKey.msgID.rawValue: msgID]
    }
}
