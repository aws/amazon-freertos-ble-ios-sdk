/// Mqtt proxy message of Pingresp.
public struct Pingresp: Encodable {

    /// Mqtt message type
    private var messageType: Int

    public init() {
        messageType = MqttMessageType.pingresp.rawValue
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w" /// CborKey.type.rawValue
    }
}
