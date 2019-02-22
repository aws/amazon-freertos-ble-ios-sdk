/// Delete network request.
public struct DeleteNetworkReq: Encborable {

    /**
     DeleteNetworkReq is used to delete a saved network.

     - Parameter Index: index of the saved network to delete.
     - Returns: A new DeleteNetworkReq.
     */
    public init(index: Int) {
        self.index = index
    }

    /// Index of the saved network to delete.
    public var index: Int

    func toDictionary() -> NSDictionary {
        return [CborKey.index.rawValue: index]
    }
}
