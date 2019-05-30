/// Notifications for operations
extension NSNotification.Name {

    // BLE Central

    /// Amazon FreeRTOS BLE Central Manager didUpdateState.
    public static let afrCentralManagerDidUpdateState: NSNotification.Name = NSNotification.Name("afrCentralManagerDidUpdateState")
    /// Amazon FreeRTOS BLE Central Manager didDiscoverDevice.
    public static let afrCentralManagerDidDiscoverDevice: NSNotification.Name = NSNotification.Name("afrCentralManagerDidDiscoverDevice")
    /// Amazon FreeRTOS BLE Central Manager didConnectDevice.
    public static let afrCentralManagerDidConnectDevice: NSNotification.Name = NSNotification.Name("afrCentralManagerDidConnectDevice")
    /// Amazon FreeRTOS BLE Central Manager didDisconnectDevice.
    public static let afrCentralManagerDidDisconnectDevice: NSNotification.Name = NSNotification.Name("afrCentralManagerDidDisconnectDevice")
    /// Amazon FreeRTOS BLE Central Manager didFailToConnectDevice.
    public static let afrCentralManagerDidFailToConnectDevice: NSNotification.Name = NSNotification.Name("afrCentralManagerDidFailToConnectDevice")

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
    /// Amazon FreeRTOS return device info afr platform.
    public static let afrDeviceInfoAfrPlatform: NSNotification.Name = NSNotification.Name("afrDeviceInfoAfrPlatform")

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
