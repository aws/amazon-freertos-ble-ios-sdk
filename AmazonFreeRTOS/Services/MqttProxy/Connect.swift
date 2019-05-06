/// Mqtt proxy message of Connect.
public struct Connect: Decborable {

    init?(dictionary: NSDictionary) {
        guard let clientID = dictionary.object(forKey: CborKey.clientID.rawValue) as? String else {
            return nil
        }
        self.clientID = clientID

        guard let brokerEndpoint = dictionary.object(forKey: CborKey.brokerEndpoint.rawValue) as? String else {
            return nil
        }
        self.brokerEndpoint = brokerEndpoint

        guard let cleanSession = dictionary.object(forKey: CborKey.cleanSession.rawValue) as? Bool else {
            return nil
        }
        self.cleanSession = cleanSession
    }

    /// Mqtt client id.
    public var clientID: String
    /// Mqtt broker endpoint.
    public var brokerEndpoint: String
    /// Mqtt clean session.
    public var cleanSession: Bool

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return Connect(dictionary: dictionary) as? T
    }
}
