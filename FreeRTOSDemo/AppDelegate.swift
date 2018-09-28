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

        // Set AWSAfrManager isDebug to true to get notification of logs, this will be replaced by AWSDDLog when release.

        AWSAfrManager.shared.isDebug = true

        // AWS SDK Logging

//        AWSDDLog.sharedInstance.logLevel = .all
//        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)

        // Setup the user sign-in with cognito: https://docs.aws.amazon.com/aws-mobile/latest/developerguide/add-aws-mobile-user-sign-in.html

        AWSServiceManager.default().defaultServiceConfiguration = AWSServiceConfiguration(region: AmazonConstants.AWS.region, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
