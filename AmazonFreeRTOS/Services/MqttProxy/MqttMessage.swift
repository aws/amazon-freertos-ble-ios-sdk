/// Generic mqtt proxy message.
public struct MqttMessage: Decborable {

    init?(dictionary: NSDictionary) {
        guard let typeRawValue = dictionary.object(forKey: CborKey.type.rawValue) as? Int, let type = MqttMessageType(rawValue: typeRawValue) else {
            return nil
        }
        self.type = type
    }

    /// Mqtt message type.
    public var type: MqttMessageType

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return MqttMessage(dictionary: dictionary) as? T
    }
}
