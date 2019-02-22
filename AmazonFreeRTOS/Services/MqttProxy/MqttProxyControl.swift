/// Mqtt proxy control.
public struct MqttProxyControl: Encborable, Decborable {

    /**
     MqttProxyControl is used to start and stop the mqtt proxy.

     - Parameter proxyState: Mqtt proxy state.
     - Returns: A new MqttProxyControl.
     */
    public init(proxyState: MqttProxyState) {
        self.proxyState = proxyState
    }

    init?(dictionary: NSDictionary) {
        guard let proxyStateRawValue = dictionary.object(forKey: CborKey.proxyState.rawValue) as? Int, let proxyState = MqttProxyState(rawValue: proxyStateRawValue) else {
            return nil
        }
        self.proxyState = proxyState
    }

    /// Mqtt proxy state.
    public var proxyState: MqttProxyState

    func toDictionary() -> NSDictionary {
        return [CborKey.proxyState.rawValue: proxyState.rawValue]
    }

    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T? {
        return MqttProxyControl(dictionary: dictionary) as? T
    }
}
