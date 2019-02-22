/// List network response.
public struct ListNetworkResp: Decborable {

    init?(dictionary: NSDictionary) {
        guard let index = dictionary.object(forKey: CborKey.index.rawValue) as? Int else {
            return nil
        }
        self.index = index

        guard let statusRawValue = dictionary.object(forKey: CborKey.status.rawValue) as? Int, let status = NetworkOpStatus(rawValue: statusRawValue) else {
            return nil
        }
        self.status = status

        guard let ssid = dictionary.object(forKey: CborKey.ssid.rawValue) as? String else {
            return nil
        }
        self.ssid = ssid

        guard let bssid = dictionary.object(forKey: CborKey.bssid.rawValue) as? String else {
            return nil
        }
        self.bssid = bssid

        guard let rssi = dictionary.object(forKey: CborKey.rssi.rawValue) as? Int else {
            return nil
        }
        self.rssi = rssi

        guard let securityRawValue = dictionary.object(forKey: CborKey.security.rawValue) as? Int, let security = NetworkSecurityType(rawValue: securityRawValue) else {
            return nil
        }
        self.security = security

        guard let hidden = dictionary.object(forKey: CborKey.hidden.rawValue) as? Bool else {
            return nil
        }
        self.hidden = hidden

        guard let connected = dictionary.object(forKey: CborKey.connected.rawValue) as? Bool else {
            return nil
        }
        self.connected = connected
    }

    /// Index of the network. < 0 for scaned networks.
    public var index: Int
    /// List operation status.
    public var status: NetworkOpStatus
    /// Wifi ssid.
    public var ssid: String
    /// Wifi bssid (Mac address).
    public var bssid: String
    /// Wifi rssi (Signal strenth).
    public var rssi: Int
    /// Wifi security type.
    public var security: NetworkSecurityType
    /// Wifi is hidden or not.
    public var hidden: Bool
    /// Wifi is connected or not.
    public var connected: Bool

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return ListNetworkResp(dictionary: dictionary) as? T
    }
}
