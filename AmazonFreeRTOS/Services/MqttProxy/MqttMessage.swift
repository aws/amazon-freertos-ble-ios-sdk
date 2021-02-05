/// Generic mqtt proxy message.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct MqttMessage: Decodable {
    /// Mqtt message type.
    public var type: MqttMessageType

    private enum CodingKeys: String, CodingKey {
        case type = "w"
    }
}
