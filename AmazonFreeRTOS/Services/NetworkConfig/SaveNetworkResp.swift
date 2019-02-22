/// Save network response.
public struct SaveNetworkResp: Decborable {

    init?(dictionary: NSDictionary) {
        guard let statusRawValue = dictionary.object(forKey: CborKey.status.rawValue) as? Int, let status = NetworkOpStatus(rawValue: statusRawValue) else {
            return nil
        }
        self.status = status
    }

    /// Save operation status.
    public var status: NetworkOpStatus

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return SaveNetworkResp(dictionary: dictionary) as? T
    }
}
