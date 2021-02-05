/// Mqtt proxy message of Connect.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Connect: Decodable {
    /// Mqtt client id.
    public var clientID: String
    /// Mqtt broker endpoint.
    public var brokerEndpoint: String
    /// Mqtt clean session.
    public var cleanSession: Bool

    private enum CodingKeys: String, CodingKey {
        case clientID = "d"
        case brokerEndpoint = "a"
        case cleanSession = "c"
    }
}
