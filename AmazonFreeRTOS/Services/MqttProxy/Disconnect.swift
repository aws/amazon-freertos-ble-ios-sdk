/// Mqtt proxy message of Disconnect.
public struct Disconnect: Decborable {

    static func toSelf<T: Decborable>(dictionary _: NSDictionary) -> T? {
        return Disconnect() as? T
    }
}
