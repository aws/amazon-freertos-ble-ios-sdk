import Foundation

/// List network request.
public struct ListNetworkReq: Codable {
    /// Max number of networks to scan.
    public var maxNetworks: Int
    /// Time to scan in seconds.
    public var timeout: Int

    /**
     ListNetworkReq is used to list saved and scanned wifi networks.

     - Parameters:
        - maxNetworks: Max number of networks to scan.
        - timeout: Time to scan in seconds.
     - Returns: A new EditNetworkReq.
     */
    public init(maxNetworks: Int, timeout: Int) {
        self.maxNetworks = maxNetworks
        self.timeout = timeout
    }
}
