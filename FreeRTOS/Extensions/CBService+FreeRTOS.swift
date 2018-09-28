import CoreBluetooth
import Foundation

extension CBService {

    /// Helper - get the characteristic for a particular UUID
    func characteristicOf(uuid: CBUUID) -> CBCharacteristic? {
        return characteristics?.first(where: { characteristic -> Bool in
            characteristic.uuid == uuid
        })
    }
}
