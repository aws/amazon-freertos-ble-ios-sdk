/// Notifications for operations
extension NSNotification.Name {

    // BLE Central

    /// FreeRTOS BLE Central Manager didUpdateState.
    public static let afrCentralManagerDidUpdateState = NSNotification.Name("afrCentralManagerDidUpdateState")
    /// FreeRTOS BLE Central Manager didDiscoverDevice.
    public static let afrCentralManagerDidDiscoverDevice = NSNotification.Name("afrCentralManagerDidDiscoverDevice")
    /// FreeRTOS BLE Central Manager didConnectDevice.
    public static let afrCentralManagerDidConnectDevice = NSNotification.Name("afrCentralManagerDidConnectDevice")
    /// FreeRTOS BLE Central Manager didDisconnectDevice.
    public static let afrCentralManagerDidDisconnectDevice = NSNotification.Name("afrCentralManagerDidDisconnectDevice")
    /// FreeRTOS BLE Central Manager didFailToConnectDevice.
    public static let afrCentralManagerDidFailToConnectDevice = NSNotification.Name("afrCentralManagerDidFailToConnectDevice")

    // BLE Peripheral

    /// FreeRTOS BLE Peripheral didDiscoverServices.
    public static let afrPeripheralDidDiscoverServices = NSNotification.Name("afrPeripheralDidDiscoverServices")
    /// FreeRTOS BLE Peripheral didDiscoverCharacteristics.
    public static let afrPeripheralDidDiscoverCharacteristics = NSNotification.Name("afrPeripheralDidDiscoverCharacteristics")

    // DeviceInfo

    /// FreeRTOS return device info afr version.
    public static let afrDeviceInfoAfrVersion = NSNotification.Name("afrDeviceInfoAfrVersion")
    /// FreeRTOS return device info broker endpoint.
    public static let afrDeviceInfoBrokerEndpoint = NSNotification.Name("afrDeviceInfoBrokerEndpoint")
    /// FreeRTOS return device info mtu.
    public static let afrDeviceInfoMtu = NSNotification.Name("afrDeviceInfoMtu")
    /// FreeRTOS return device info afr platform.
    public static let afrDeviceInfoAfrPlatform = NSNotification.Name("afrDeviceInfoAfrPlatform")
    /// FreeRTOS return device info afr dev id.
    public static let afrDeviceInfoAfrDevId = NSNotification.Name("afrDeviceInfoAfrDevId")

    // NetworkConfig

    /// FreeRTOS list network returned a saved or scaned network.
    public static let afrDidListNetwork = NSNotification.Name("afrDidListNetwork")
    /// FreeRTOS save network did save a network.
    public static let afrDidSaveNetwork = NSNotification.Name("afrDidSaveNetwork")
    /// FreeRTOS edit network did edit a saved network.
    public static let afrDidEditNetwork = NSNotification.Name("afrDidEditNetwork")
    /// FreeRTOS delete network did delete a saved network.
    public static let afrDidDeleteNetwork = NSNotification.Name("afrDidDeleteNetwork")
}
