/// Mqtt proxy message of Subscribe.
public struct Subscribe: Decodable {
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoSs.
    public var qoSs: [Int]

    private enum CodingKeys: String, CodingKey {
        case topics = "v" /// CborKey.topics.rawValue
        case msgID = "i" /// CborKey.msgID.rawValue
        case qoSs = "o" /// CborKey.qoSs.rawValue
    }
}
