/// Save network response.
public struct SaveNetworkResp: Decodable {
    /// Save operation status.
    public var status: NetworkOpStatus

    private enum CodingKeys: String, CodingKey {
        case status = "s" /// CborKey.status.rawValue
    }
}
