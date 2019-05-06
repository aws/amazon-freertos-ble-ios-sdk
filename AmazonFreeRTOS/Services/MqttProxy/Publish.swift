/// Mqtt proxy message of Publish.
public struct Publish: Encborable, Decborable {

    /// Publish msg init (internal).
    ///
    /// - Parameters:
    ///     - topic: Mqtt topic.
    ///     - msgID: Mqtt message id.
    ///     - qoS: Mqtt QoS.
    ///     - payload: Mqtt payload.
    /// - Returns: A new SaveNetworkReq.
    public init(topic: String, msgID: Int, qoS: Int, payload: Data) {
        self.topic = topic
        self.msgID = msgID
        self.qoS = qoS
        self.payload = payload
    }

    init?(dictionary: NSDictionary) {
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

        guard let payload = dictionary.object(forKey: CborKey.payload.rawValue) as? String, let data = payload.data else {
            return nil
        }
        self.payload = data
    }

    /// Mqtt topic.
    public var topic: String
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoS.
    public var qoS: Int
    /// Mqtt payload.
    public var payload: Data

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: MqttMessageType.publish.rawValue, CborKey.topic.rawValue: topic, CborKey.msgID.rawValue: msgID, CborKey.qoS.rawValue: qoS, CborKey.payload.rawValue: NSByteString(payload.hex)]
    }

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return Publish(dictionary: dictionary) as? T
    }
}
