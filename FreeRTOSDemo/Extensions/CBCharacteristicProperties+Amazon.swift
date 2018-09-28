import CoreBluetooth
import Foundation

extension CBCharacteristicProperties {

    /// Helper - provide properties string for the characteristic.
    func propertiesString() -> String {

        var propertiesStr = String()

        if (rawValue & CBCharacteristicProperties.broadcast.rawValue) != 0 {
            propertiesStr += "broadcast  "
        }
        if (rawValue & CBCharacteristicProperties.read.rawValue) != 0 {
            propertiesStr += "read  "
        }
        if (rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
            propertiesStr += "write without response  "
        }
        if (rawValue & CBCharacteristicProperties.write.rawValue) != 0 {
            propertiesStr += "write  "
        }
        if (rawValue & CBCharacteristicProperties.notify.rawValue) != 0 {
            propertiesStr += "notify  "
        }
        if (rawValue & CBCharacteristicProperties.indicate.rawValue) != 0 {
            propertiesStr += "indicate  "
        }
        if (rawValue & CBCharacteristicProperties.authenticatedSignedWrites.rawValue) != 0 {
            propertiesStr += "authenticated signed writes  "
        }
        if (rawValue & CBCharacteristicProperties.extendedProperties.rawValue) != 0 {
            propertiesStr += "indicate  "
        }
        if (rawValue & CBCharacteristicProperties.notifyEncryptionRequired.rawValue) != 0 {
            propertiesStr += "notify encryption required  "
        }
        if (rawValue & CBCharacteristicProperties.indicateEncryptionRequired.rawValue) != 0 {
            propertiesStr += "indicate encryption required  "
        }
        return propertiesStr
    }
}
