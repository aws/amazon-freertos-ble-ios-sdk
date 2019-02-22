/// Notifications for operations
extension NSNotification.Name {

    // BLE Central

    /// Amazon FreeRTOS BLE Central Manager didUpdateState.
    public static let afrCentralManagerDidUpdateState: NSNotification.Name = NSNotification.Name("afrCentralManagerDidUpdateState")
    /// Amazon FreeRTOS BLE Central Manager didDiscoverPeripheral.
    public static let afrCentralManagerDidDiscoverPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidDiscoverPeripheral")
    /// Amazon FreeRTOS BLE Central Manager didConnectPeripheral.
    public static let afrCentralManagerDidConnectPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidConnectPeripheral")
    /// Amazon FreeRTOS BLE Central Manager didDisconnectPeripheral.
    public static let afrCentralManagerDidDisconnectPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidDisconnectPeripheral")
    /// Amazon FreeRTOS BLE Central Manager didFailToConnectPeripheral.
    public static let afrCentralManagerDidFailToConnectPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidFailToConnectPeripheral")

    // BLE Peripheral

    /// Amazon FreeRTOS BLE Peripheral didDiscoverServices.
    public static let afrPeripheralDidDiscoverServices: NSNotification.Name = NSNotification.Name("afrPeripheralDidDiscoverServices")
    /// Amazon FreeRTOS BLE Peripheral didDiscoverCharacteristics.
    public static let afrPeripheralDidDiscoverCharacteristics: NSNotification.Name = NSNotification.Name("afrPeripheralDidDiscoverCharacteristics")

    // DeviceInfo

    /// Amazon FreeRTOS return device info afr version.
    public static let afrDeviceInfoAfrVersion: NSNotification.Name = NSNotification.Name("afrDeviceInfoAfrVersion")
    /// Amazon FreeRTOS return device info broker endpoint.
    public static let afrDeviceInfoBrokerEndpoint: NSNotification.Name = NSNotification.Name("afrDeviceInfoBrokerEndpoint")
    /// Amazon FreeRTOS return device info mtu.
    public static let afrDeviceInfoMtu: NSNotification.Name = NSNotification.Name("afrDeviceInfoMtu")

    // MqttProxy

    /// Amazon FreeRTOS return mqtt proxy control.
    public static let afrMqttProxyControl: NSNotification.Name = NSNotification.Name("afrMqttProxyControl")

    // NetworkConfig

    /// Amazon FreeRTOS list network returned a saved or scaned network.
    public static let afrDidListNetwork: NSNotification.Name = NSNotification.Name("afrDidListNetwork")
    /// Amazon FreeRTOS save network did save a network.
    public static let afrDidSaveNetwork: NSNotification.Name = NSNotification.Name("afrDidSaveNetwork")
    /// Amazon FreeRTOS edit network did edit a saved network.
    public static let afrDidEditNetwork: NSNotification.Name = NSNotification.Name("afrDidEditNetwork")
    /// Amazon FreeRTOS delete network did delete a saved network.
    public static let afrDidDeleteNetwork: NSNotification.Name = NSNotification.Name("afrDidDeleteNetwork")
}
