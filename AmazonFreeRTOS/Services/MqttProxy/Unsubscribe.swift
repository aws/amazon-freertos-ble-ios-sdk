import Foundation

/// Mqtt proxy message of Unsubscribe.
public struct Unsubscribe: Decborable {

    init?(dictionary: NSDictionary) {
        guard let typeRawValue = dictionary.object(forKey: CborKey.type.rawValue) as? Int, let type = MqttMessageType(rawValue: typeRawValue) else {
            return nil
        }
        self.type = type

        guard let topics = dictionary.object(forKey: CborKey.topics.rawValue) as? [String] else {
            return nil
        }
        self.topics = topics

        guard let msgID = dictionary.object(forKey: CborKey.msgID.rawValue) as? Int else {
            return nil
        }
        self.msgID = msgID
    }

    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return Unsubscribe(dictionary: dictionary) as? T
    }
}
