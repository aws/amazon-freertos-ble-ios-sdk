import CoreBluetooth
import Foundation

extension CBPeripheral {

    /// Helper - get the service for a particular UUID
    func serviceOf(uuid: CBUUID) -> CBService? {
        return services?.first(where: { service -> Bool in
            service.uuid == uuid
        })
    }
}
