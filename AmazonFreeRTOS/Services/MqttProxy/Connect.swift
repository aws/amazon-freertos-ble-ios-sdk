/// Mqtt proxy message of Connect.
public struct Connect: Decodable {
    /// Mqtt client id.
    public var clientID: String
    /// Mqtt broker endpoint.
    public var brokerEndpoint: String
    /// Mqtt clean session.
    public var cleanSession: Bool

    private enum CodingKeys: String, CodingKey {
        case clientID = "d" /// CborKey.clientID.rawValue
        case brokerEndpoint = "a" /// CborKey.brokerEndpoint.rawValue
        case cleanSession = "c" /// CborKey.cleanSession.rawValue
    }
}
