import CBORSwift
import Foundation

/// Save network request.
public struct SaveNetworkReq: Encborable {
    
    /**
     SaveNetworkReq is used to save wifi network.
     
     - Parameters:
        - index: Index of the network.
        - ssid: Wifi ssid.
        - bssid: Wifi bssid (Mac address).
        - psk: Wifi password. Saved network ignore this value.
        - security: Wifi security type.
     - Returns: A new SaveNetworkReq.
     */
    public init(index: Int, ssid: String, bssid: String, psk: String, security: NetworkSecurityType, connect: Bool) {
        self.index = index
        self.ssid = ssid
        self.bssid = bssid
        self.psk = psk
        self.security = security
    }
    
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

    func toDictionary() -> NSDictionary {
        return [CborKey.index.rawValue: index, CborKey.ssid.rawValue: ssid, CborKey.bssid.rawValue: NSByteString(bssid), CborKey.psk.rawValue: psk, CborKey.security.rawValue: security.rawValue]
    }
}
