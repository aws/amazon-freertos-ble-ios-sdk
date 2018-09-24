import Foundation

struct ListNetworkResp: Codable {
    var status: NetworkStatus
    var ssid, bssid: String
    var security: NetworkSecurityType
    var hidden, connected: Bool
    var rssi, index: Int
}
