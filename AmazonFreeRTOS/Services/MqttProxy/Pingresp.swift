/// Mqtt proxy message of Pingresp.
public struct Pingresp: Encborable {

    func toDictionary() -> NSDictionary {
        return [CborKey.type.rawValue: MqttMessageType.pingresp.rawValue]
    }
}
