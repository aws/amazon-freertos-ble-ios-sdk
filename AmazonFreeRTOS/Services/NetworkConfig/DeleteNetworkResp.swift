/// Delete network response.
public struct DeleteNetworkResp: Decborable {

    init?(dictionary: NSDictionary) {
        guard let statusRawValue = dictionary.object(forKey: CborKey.status.rawValue) as? Int, let status = NetworkOpStatus(rawValue: statusRawValue) else {
            return nil
        }
        self.status = status
    }

    /// Delete operation status.
    public var status: NetworkOpStatus

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return DeleteNetworkResp(dictionary: dictionary) as? T
    }
}
