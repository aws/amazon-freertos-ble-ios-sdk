import AWSCore
import CoreBluetooth
import Foundation

struct AmazonConstants {

    struct AWS {
        static let region = AWSRegionType.USWest2
        static let iotPolicyName = "freerots"
        static let mqttCustomTopic = "my/custom/topic"
    }
}
