import CoreBluetooth

/// FreeRTOS Constants
public enum AmazonFreeRTOS {
    /// FreeRTOS SDK Version.
    static let SDKVersion = "1.1.0"
}

/// BLE services used by the SDK.
public enum AmazonFreeRTOSGattService {
    /// Device Info Service. This is a required service for FreeRTOS.
    static let DeviceInfo = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932ff00")
    /// Mqtt Proxy Service.
    static let MqttProxy = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30000")
    /// Network Config Service.
    static let NetworkConfig = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30100")
}

/// BLE characteristics used by the SDK.
public enum AmazonFreeRTOSGattCharacteristic {
    /// The version of the FreeRTOS.
    static let AfrVersion = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932ff01")
    /// The broker endpoint of the mqtt.
    static let BrokerEndpoint = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932ff02")
    /// The mtu of the device.
    static let Mtu = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932ff03")
    /// The platform of the FreeRTOS.
    static let AfrPlatform = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932ff04")
    /// The device id of the FreeRTOS.
    static let AfrDevId = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932ff05")

    /// Used for mqtt control state.
    static let MqttProxyControl = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30001")
    /// Used for transfer mqtt messages.
    static let TXMqttMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30002")
    /// Used for transfer mqtt messages.
    static let RXMqttMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30003")
    /// Used for mqtt large object transfer.
    static let TXLargeMqttMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30004")
    /// Used for mqtt large object transfer.
    static let RXLargeMqttMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30005")

    /// Used for network control state.
    static let NetworkConfigControl = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30101")
    /// Used for transfer network messages.
    static let TXNetworkMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30102")
    /// Used for transfer network messages.
    static let RXNetworkMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30103")
    /// Used for network large object transfer.
    static let TXLargeNetworkMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30104")
    /// Used for network large object transfer.
    static let RXLargeNetworkMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc30105")
}
