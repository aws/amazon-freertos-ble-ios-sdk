import Foundation

/// Delete network request.
public struct DeleteNetworkReq: Codable {
    /// Index of the saved network to delete.
    public var index: Int

    /**
     DeleteNetworkReq is used to delete a saved network.

     - Parameter Index: index of the saved network to delete.
     - Returns: A new DeleteNetworkReq.
     */
    public init(index: Int) {
        self.index = index
    }
}
