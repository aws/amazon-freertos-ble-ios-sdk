import Foundation

/// Device info message of MTU.
struct Mtu: Codable {
    /// Device info message type.
    var type: DeviceInfoMessageType
    /// Current BLE MTU size
    var mtu: Int
}
