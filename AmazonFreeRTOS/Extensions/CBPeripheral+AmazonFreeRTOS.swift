import CoreBluetooth

extension CBPeripheral {

    /// Helper - get the service for a particular UUID
    public func serviceOf(uuid: CBUUID) -> CBService? {
        return services?.first(where: { service -> Bool in
            service.uuid == uuid
        })
    }
}
