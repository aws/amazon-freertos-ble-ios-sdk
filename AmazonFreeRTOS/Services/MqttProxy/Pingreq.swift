/// Mqtt proxy message of Pingreq.
public struct Pingreq: Decborable {

    static func toSelf<T: Decborable>(dictionary _: NSDictionary) -> T? {
        return Pingreq() as? T
    }
}
