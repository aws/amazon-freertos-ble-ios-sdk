/// Edit network request.
public struct EditNetworkReq: Encodable {

    /// message type
    private var messageType: Int
    /// Old index of the saved network.
    public var index: Int
    /// New index of the saved network.
    public var newIndex: Int

    /// EditNetworkReq is used to update the priority of a saved network.
    ///
    /// - Parameters:
    ///     - index: Old index of the saved network.
    ///     - newIndex: New index of the saved network.
    /// - Returns: A new EditNetworkReq.
    public init(index: Int, newIndex: Int) {
        messageType = NetworkMessageType.editNetworkReq.rawValue
        self.index = index
        self.newIndex = newIndex
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
        case index = "g" /// CborKey.index.rawValue
        case newIndex = "j" /// CborKey.newIndex.rawValue
    }
}
