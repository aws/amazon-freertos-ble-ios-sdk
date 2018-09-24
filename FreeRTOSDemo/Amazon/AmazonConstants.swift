import AWSCore
import CoreBluetooth
import Foundation

struct AmazonConstants {

    struct AWS {
        static let region = AWSRegionType.USWest2
        static let iotEndpoint = AWSEndpoint(urlString: "https://a3t5kecidjae9r.iot.us-west-2.amazonaws.com")
        static let mqttCustomTopic = "custom"
    }
}
