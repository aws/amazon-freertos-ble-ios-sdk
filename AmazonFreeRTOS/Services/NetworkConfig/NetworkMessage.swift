/// Generic network config message.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct NetworkMessage: Decodable {
    /// Network message type.
    public var type: NetworkMessageType

    private enum CodingKeys: String, CodingKey {
        case type = "w"
    }
}
