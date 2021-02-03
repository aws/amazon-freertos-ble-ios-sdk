/// Edit network response.
public struct EditNetworkResp: Decodable {
    /// Edit operation status.
    public var status: NetworkOpStatus

    private enum CodingKeys: String, CodingKey {
        case status = "s" /// CborKey.status.rawValue
    }
}
