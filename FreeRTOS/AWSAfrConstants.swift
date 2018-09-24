import CoreBluetooth
import Foundation

/// BLE services used by the SDK.
struct AWSAfrGattService {
    /// FreeRTOS UUID is only for scanForPeripherals filter, it's not a real service on the device. Please use your custom uuid if you have changed the device's advertisement data.
    static let FreeRTOS = CBUUID(string: "8a7f1168-48af-4efb-83b5-e679f932db5a")

    /// Mqtt Proxy Service.
    static let Mqtt = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc3ff00")
    /// Network Config Service.
    static let Network = CBUUID(string: "3113a187-4b9f-4f9a-aa83-c614e11bff00")
}

/// BLE characteristics used by the SDK.
struct AWSAfrGattCharacteristic {
    /// Provide’s basic metadata such as MTU.
    static let Metadata = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc3ff01")
    /// Used for transfer mqtt messages.
    static let TXMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc3ff02")
    /// Used for transfer mqtt messages.
    static let RXMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc3ff03")
    /// Used for large object transfer.
    static let TXLargeMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc3ff04")
    /// Used for large object transfer.
    static let RXLargeMessage = CBUUID(string: "a9d7166a-d72e-40a9-a002-48044cc3ff05")

    /// List saved and scanned wifi networks.
    static let ListNetwork = CBUUID(string: "3113a187-4b9f-4f9a-aa83-c614e11bff01")
    /// Save wifi network.
    static let SaveNetwork = CBUUID(string: "3113a187-4b9f-4f9a-aa83-c614e11bff02")
    /// Edit wifi network.
    static let EditNetwork = CBUUID(string: "3113a187-4b9f-4f9a-aa83-c614e11bff03")
    /// Delete saved wifi network
    static let DeleteNetwork = CBUUID(string: "3113a187-4b9f-4f9a-aa83-c614e11bff04")
}
