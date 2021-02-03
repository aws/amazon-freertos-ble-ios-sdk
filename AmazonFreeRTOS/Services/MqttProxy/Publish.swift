/// Mqtt proxy message of Publish.
public struct Publish: Codable {
    /// Mqtt message type
    private var messageType: Int
    /// Mqtt topic.
    public var topic: String
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoS.
    public var qoS: Int
    /// Mqtt payload.
    public var payload: Data

    /// Publish msg init (internal).
    ///
    /// - Parameters:
    ///     - topic: Mqtt topic.
    ///     - msgID: Mqtt message id.
    ///     - qoS: Mqtt QoS.
    ///     - payload: Mqtt payload.
    /// - Returns: A new SaveNetworkReq.
    public init(topic: String, msgID: Int, qoS: Int, payload: Data) {
        messageType = MqttMessageType.publish.rawValue
        self.topic = topic
        self.msgID = msgID
        self.qoS = qoS
        self.payload = payload
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
        case topic = "u" /// CborKey.topic.rawValue
        case msgID = "i" /// CborKey.msgID.rawValue
        case qoS = "n" /// CborKey.qoS.rawValue
        case payload = "k" /// CborKey.payload.rawValue
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageType = try values.decode(Int.self, forKey: .messageType)
        topic = try values.decode(String.self, forKey: .topic)

        if values.contains(.msgID) {
            msgID = try values.decode(Int.self, forKey: .msgID)
        } else {
            msgID = 0
        }

        qoS = try values.decode(Int.self, forKey: .qoS)
        payload = try values.decode(Data.self, forKey: .payload)
    }
}
