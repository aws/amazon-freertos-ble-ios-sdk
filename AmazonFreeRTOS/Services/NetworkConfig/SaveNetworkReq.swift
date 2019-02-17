import Foundation

/// Save network request.
public struct SaveNetworkReq: Codable {
    /// Index of the network.
    public var index: Int
    /// Wifi ssid.
    public var ssid: String
    /// Wifi bssid (Mac address).
    public var bssid: String
    /// Wifi password. Saved network ignore this value.
    public var psk: String
    /// Wifi security type.
    public var security: NetworkSecurityType
    /// Connect immediately.
    public var connect: Bool

    /**
     SaveNetworkReq is used to save wifi network.

     - Parameters:
        - index: Index of the network.
        - ssid: Wifi ssid.
        - bssid: Wifi bssid (Mac address).
        - psk: Wifi password. Saved network ignore this value.
        - security: Wifi security type.
        - connect: Connect immediately.
     - Returns: A new SaveNetworkReq.
     */
    public init(index: Int, ssid: String, bssid: String, psk: String, security: NetworkSecurityType, connect: Bool) {
        self.index = index
        self.ssid = ssid
        self.bssid = bssid
        self.psk = psk
        self.security = security
        self.connect = connect
    }
}
