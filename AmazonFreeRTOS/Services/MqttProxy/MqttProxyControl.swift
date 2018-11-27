import Foundation

/// Mqtt proxy control.
public struct MqttProxyControl: Codable {
    /// Mqtt proxy state.
    public var proxyState: MqttProxyState

    /**
     MqttProxyControl is used to start and stop the mqtt proxy.

     - Parameter proxyState: Mqtt proxy state.
     - Returns: A new MqttProxyControl.
     */
    public init(proxyState: MqttProxyState) {
        self.proxyState = proxyState
    }
}
