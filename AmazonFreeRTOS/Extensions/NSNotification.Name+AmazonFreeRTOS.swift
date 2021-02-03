/// Notifications for operations
extension NSNotification.Name {

    // BLE Central

    /// FreeRTOS BLE Central Manager didUpdateState.
    static let afrCentralManagerDidUpdateState = NSNotification.Name("afrCentralManagerDidUpdateState")
    /// FreeRTOS BLE Central Manager didDiscoverDevice.
    static let afrCentralManagerDidDiscoverDevice = NSNotification.Name("afrCentralManagerDidDiscoverDevice")
    /// FreeRTOS BLE Central Manager didConnectDevice.
    static let afrCentralManagerDidConnectDevice = NSNotification.Name("afrCentralManagerDidConnectDevice")
    /// FreeRTOS BLE Central Manager didDisconnectDevice.
    static let afrCentralManagerDidDisconnectDevice = NSNotification.Name("afrCentralManagerDidDisconnectDevice")
    /// FreeRTOS BLE Central Manager didFailToConnectDevice.
    static let afrCentralManagerDidFailToConnectDevice = NSNotification.Name("afrCentralManagerDidFailToConnectDevice")

    // BLE Peripheral

    /// FreeRTOS BLE Peripheral didDiscoverServices.
    static let afrPeripheralDidDiscoverServices = NSNotification.Name("afrPeripheralDidDiscoverServices")
    /// FreeRTOS BLE Peripheral didDiscoverCharacteristics.
    static let afrPeripheralDidDiscoverCharacteristics = NSNotification.Name("afrPeripheralDidDiscoverCharacteristics")

    // DeviceInfo

    /// FreeRTOS return device info afr version.
    static let afrDeviceInfoAfrVersion = NSNotification.Name("afrDeviceInfoAfrVersion")
    /// FreeRTOS return device info broker endpoint.
    static let afrDeviceInfoBrokerEndpoint = NSNotification.Name("afrDeviceInfoBrokerEndpoint")
    /// FreeRTOS return device info mtu.
    static let afrDeviceInfoMtu = NSNotification.Name("afrDeviceInfoMtu")
    /// FreeRTOS return device info afr platform.
    static let afrDeviceInfoAfrPlatform = NSNotification.Name("afrDeviceInfoAfrPlatform")
    /// FreeRTOS return device info afr dev id.
    static let afrDeviceInfoAfrDevId = NSNotification.Name("afrDeviceInfoAfrDevId")

    // NetworkConfig

    /// FreeRTOS list network returned a saved or scaned network.
    static let afrDidListNetwork = NSNotification.Name("afrDidListNetwork")
    /// FreeRTOS save network did save a network.
    static let afrDidSaveNetwork = NSNotification.Name("afrDidSaveNetwork")
    /// FreeRTOS edit network did edit a saved network.
    static let afrDidEditNetwork = NSNotification.Name("afrDidEditNetwork")
    /// FreeRTOS delete network did delete a saved network.
    static let afrDidDeleteNetwork = NSNotification.Name("afrDidDeleteNetwork")
}
