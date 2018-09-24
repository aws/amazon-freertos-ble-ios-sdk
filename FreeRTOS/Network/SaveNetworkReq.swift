import Foundation

struct SaveNetworkReq: Codable {
    var ssid, bssid, psk: String
    var security: NetworkSecurityType
    var index: Int
}
