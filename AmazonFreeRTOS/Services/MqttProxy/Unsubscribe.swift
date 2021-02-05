/// Mqtt proxy message of Unsubscribe.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Unsubscribe: Decodable {
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int

    private enum CodingKeys: String, CodingKey {
        case topics = "v"
        case msgID = "i"
    }
}
