/// Generic network config message.
public struct NetworkMessage: Decborable {

    init?(dictionary: NSDictionary) {
        guard let typeRawValue = dictionary.object(forKey: CborKey.type.rawValue) as? Int, let type = NetworkMessageType(rawValue: typeRawValue) else {
            return nil
        }
        self.type = type
    }

    /// Network message type.
    public var type: NetworkMessageType

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return NetworkMessage(dictionary: dictionary) as? T
    }
}
