/// Edit network response.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct EditNetworkResp: Decodable {
    /// Edit operation status.
    public var status: NetworkOpStatus

    private enum CodingKeys: String, CodingKey {
        case status = "s"
    }
}
