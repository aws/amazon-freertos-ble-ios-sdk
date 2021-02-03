/// Generic network config message.
public struct NetworkMessage: Decodable {
    /// Network message type.
    public var type: NetworkMessageType

    private enum CodingKeys: String, CodingKey {
        case type = "w" /// CborKey.type.rawValue
    }
}
