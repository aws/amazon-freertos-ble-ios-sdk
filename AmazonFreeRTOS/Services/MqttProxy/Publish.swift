import CBORSwift
import Foundation

/// Mqtt proxy message of Publish.
public struct Publish: Encborable, Decborable {

    public init(type: MqttMessageType, topic: String, msgID: Int, qoS: Int, payloadVal: Data) {
        self.type = type
        self.topic = topic
        self.msgID = msgID
        self.qoS = qoS
        self.payloadVal = payloadVal
    }

    init?(dictionary: NSDictionary) {
        guard let typeRawValue = dictionary.object(forKey: CborKey.type.rawValue) as? Int, let type = MqttMessageType(rawValue: typeRawValue) else {
            return nil
        }
        self.type = type

        guard let topic = dictionary.object(forKey: CborKey.topic.rawValue) as? String else {
            return nil
        }
        self.topic = topic

        if let msgID = dictionary.object(forKey: CborKey.msgID.rawValue) as? Int {
            self.msgID = msgID
        } else {
            msgID = 0
        }

        guard let qoS = dictionary.object(forKey: CborKey.qoS.rawValue) as? Int else {
            return nil
        }
        self.qoS = qoS

        guard let payloadVal = dictionary.object(forKey: CborKey.payloadVal.rawValue) as? String, let data = payloadVal.data else {
            return nil
        }
        self.payloadVal = data
    }

    /// Mqtt message type.
    public var type: MqttMessageType
    /// Mqtt topic.
    public var topic: String
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoS.
    public var qoS: Int
    /// Mqtt payload.
    public var payloadVal: Data

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: type.rawValue, CborKey.topic.rawValue: topic, CborKey.msgID.rawValue: msgID, CborKey.qoS.rawValue: qoS, CborKey.payloadVal.rawValue: NSByteString(payloadVal.hex)]
    }

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return Publish(dictionary: dictionary) as? T
    }
}
