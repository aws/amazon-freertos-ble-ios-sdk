/// List network request.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct ListNetworkReq: Encodable {

    /// message type
    private var messageType: Int
    /// Max number of networks to scan.
    public var maxNetworks: Int
    /// Time to scan in seconds.
    public var timeout: Int

    /// ListNetworkReq is used to list saved and scanned wifi networks.
    ///
    /// - Parameters:
    ///     - maxNetworks: Max number of networks to scan.
    ///     - timeout: Time to scan in seconds.
    /// - Returns: A new EditNetworkReq.
    public init(maxNetworks: Int, timeout: Int) {
        messageType = NetworkMessageType.listNetworkReq.rawValue
        self.maxNetworks = maxNetworks
        self.timeout = timeout
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w"
        case maxNetworks = "h"
        case timeout = "t"
    }
}
