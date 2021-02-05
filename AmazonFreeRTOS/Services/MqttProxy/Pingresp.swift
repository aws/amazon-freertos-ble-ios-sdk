/// Mqtt proxy message of Pingresp.
/// To reduce the encoded CBOR message size, we maps the variable name with a single character by CodingKey
/// Check the "CborKey" Enum to see the mapping relationship.
public struct Pingresp: Encodable {

    /// Mqtt message type
    private var messageType: Int

    public init() {
        messageType = MqttMessageType.pingresp.rawValue
    }

    private enum CodingKeys: String, CodingKey {
        case messageType = "w"
    }
}
