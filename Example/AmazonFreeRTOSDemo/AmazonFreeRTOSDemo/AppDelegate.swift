import AmazonFreeRTOS
import AWSMobileClient
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Appearance

        window?.backgroundColor = .white
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).shadowImage = UIImage()
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "teal_color")

        // FreeRTOS SDK Logging, will switch to AWSDDLog in future releases

        _ = AmazonContext.shared
        AmazonFreeRTOSManager.shared.isDebug = true

        // Override advertising Service UUIDs if needed.

        // AmazonFreeRTOSManager.shared.advertisingServiceUUIDs = []
        // AmazonFreeRTOSManager.shared.serviceUUIDs = []

        // AWS SDK Logging

        // AWSDDLog.sharedInstance.logLevel = .all
        // AWSDDLog.add(AWSDDTTYLogger.sharedInstance)

        // Setup the user sign-in with cognito: https://aws-amplify.github.io/docs/ios/authentication#manual-setup

        AWSServiceManager.default().defaultServiceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, credentialsProvider: AWSMobileClient.sharedInstance())
        return true
    }
}
