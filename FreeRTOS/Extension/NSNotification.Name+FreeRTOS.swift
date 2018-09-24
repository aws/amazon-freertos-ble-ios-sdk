import Foundation

/// Notifications for operations
extension NSNotification.Name {

    //
    static let didDiscoverPeripheral: NSNotification.Name = NSNotification.Name("didDiscoverPeripheral")
    static let didDiscoverServices: NSNotification.Name = NSNotification.Name("didDiscoverServices")
    static let didDiscoverCharacteristics: NSNotification.Name = NSNotification.Name("didDiscoverCharacteristics")

    static let didListNetwork: NSNotification.Name = NSNotification.Name("didListNetwork")
    static let didSaveNetwork: NSNotification.Name = NSNotification.Name("didSaveNetwork")
    static let didEditNetwork: NSNotification.Name = NSNotification.Name("didEditNetwork")
    static let didDeleteNetwork: NSNotification.Name = NSNotification.Name("didDeleteNetwork")

    #warning("delete")

    static let debugPrint: NSNotification.Name = NSNotification.Name("debugPrint")

    #warning("delete")
}
