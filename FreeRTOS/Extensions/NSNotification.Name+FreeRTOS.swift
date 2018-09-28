import Foundation

/// Notifications for operations
extension NSNotification.Name {

    // BLE Central

    /// AFR BLE Central Manager didUpdateState.
    static let afrCentralManagerDidUpdateState: NSNotification.Name = NSNotification.Name("afrCentralManagerDidUpdateState")
    /// AFR BLE Central Manager didDiscoverPeripheral.
    static let afrCentralManagerDidDiscoverPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidDiscoverPeripheral")
    /// AFR BLE Central Manager didConnectPeripheral.
    static let afrCentralManagerDidConnectPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidConnectPeripheral")
    /// AFR BLE Central Manager didDisconnectPeripheral.
    static let afrCentralManagerDidDisconnectPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidDisconnectPeripheral")
    /// AFR BLE Central Manager didFailToConnectPeripheral.
    static let afrCentralManagerDidFailToConnectPeripheral: NSNotification.Name = NSNotification.Name("afrCentralManagerDidFailToConnectPeripheral")

    // BLE Peripheral

    /// AFR BLE Peripheral didDiscoverServices.
    static let afrPeripheralDidDiscoverServices: NSNotification.Name = NSNotification.Name("afrPeripheralDidDiscoverServices")
    /// AFR BLE Peripheral didDiscoverCharacteristics.
    static let afrPeripheralDidDiscoverCharacteristics: NSNotification.Name = NSNotification.Name("afrPeripheralDidDiscoverCharacteristics")

    // DeviceInfo

    /// AFR return device info afr version.
    static let afrDeviceInfoAfrVersion: NSNotification.Name = NSNotification.Name("afrDeviceInfoAfrVersion")
    /// AFR return device info broker endpoint.
    static let afrDeviceInfoBrokerEndpoint: NSNotification.Name = NSNotification.Name("afrDeviceInfoBrokerEndpoint")
    /// AFR return device info mtu.
    static let afrDeviceInfoMtu: NSNotification.Name = NSNotification.Name("afrDeviceInfoMtu")

    // MqttProxy

    /// AFR return mqtt proxy control.
    static let afrMqttProxyControl: NSNotification.Name = NSNotification.Name("afrMqttProxyControl")

    // NetworkConfig

    /// AFR list network returned a saved or scaned network.
    static let afrDidListNetwork: NSNotification.Name = NSNotification.Name("afrDidListNetwork")
    /// AFR save network did save a network.
    static let afrDidSaveNetwork: NSNotification.Name = NSNotification.Name("afrDidSaveNetwork")
    /// AFR edit network did edit a saved network.
    static let afrDidEditNetwork: NSNotification.Name = NSNotification.Name("afrDidEditNetwork")
    /// AFR delete network did delete a saved network.
    static let afrDidDeleteNetwork: NSNotification.Name = NSNotification.Name("afrDidDeleteNetwork")

    #warning("will be removed on public release")

    static let debugPrint: NSNotification.Name = NSNotification.Name("debugPrint")

    #warning("will be removed on public release")
}
