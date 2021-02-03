/// Mqtt proxy message of Unsubscribe.
public struct Unsubscribe: Decodable {
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int

    private enum CodingKeys: String, CodingKey {
        case topics = "v" /// CborKey.topics.rawValue
        case msgID = "i" /// CborKey.msgID.rawValue
    }
}
