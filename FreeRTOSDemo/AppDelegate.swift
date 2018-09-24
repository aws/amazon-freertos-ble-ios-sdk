import AWSCore
import AWSMobileClient
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Appearance

        window?.backgroundColor = .white
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).shadowImage = UIImage()
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "teal_color")

        // Manager

        AWSAfrManager.shared.isDebug = true

        // AWS

//        AWSDDLog.sharedInstance.logLevel = .all
//        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)

        AWSServiceManager.default().defaultServiceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
