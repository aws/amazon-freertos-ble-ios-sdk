import Foundation

/// Control message for mqtt proxy.
struct ControlMessage: Codable {
    /// Mqtt proxy state.
    var proxyState: MqttProxyState
}
