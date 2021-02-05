/// Mqtt proxy message of Subscribe.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Subscribe: Decodable {
    /// Mqtt topics.
    public var topics: [String]
    /// Mqtt message id.
    public var msgID: Int
    /// Mqtt QoSs.
    public var qoSs: [Int]

    private enum CodingKeys: String, CodingKey {
        case topics = "v"
        case msgID = "i"
        case qoSs = "o"
    }
}
