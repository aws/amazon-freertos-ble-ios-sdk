/// Generic mqtt proxy message.
public struct MqttMessage: Decodable {
    /// Mqtt message type.
    public var type: MqttMessageType

    private enum CodingKeys: String, CodingKey {
        case type = "w" /// CborKey.type.rawValue
    }
}
