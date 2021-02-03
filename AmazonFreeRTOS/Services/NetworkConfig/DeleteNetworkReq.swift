/// Delete network request.
public struct DeleteNetworkReq: Encodable {

    /// message type
    private var messageType: Int
    /// Index of the saved network to delete.
    public var index: Int

    /// DeleteNetworkReq is used to delete a saved network.
    ///
    /// - Parameter Index: index of the saved network to delete.
    /// - Returns: A new DeleteNetworkReq.
    public init(index: Int) {
        messageType = NetworkMessageType.deleteNetworkReq.rawValue
        self.index = index
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
        case index = "g" /// CborKey.index.rawValue
    }
}
