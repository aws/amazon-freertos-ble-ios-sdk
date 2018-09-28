import Foundation

/// Control for mqtt proxy.
struct Control: Codable {
    /// Mqtt proxy state.
    var proxyState: MqttProxyState
}
