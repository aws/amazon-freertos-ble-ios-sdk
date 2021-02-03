/// Delete network response.
public struct DeleteNetworkResp: Decodable {
    /// Delete operation status.
    public var status: NetworkOpStatus

    private enum CodingKeys: String, CodingKey {
        case status = "s" /// CborKey.status.rawValue
    }
}
