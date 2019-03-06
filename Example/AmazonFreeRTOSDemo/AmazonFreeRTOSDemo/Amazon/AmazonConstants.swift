import AWSCore

struct AmazonConstants {

    struct AWS {

        #error("Replace with your AWS Region. eg: AWSRegionType.USEast1")

        static let region = AWSRegionType.USEast1

        #error("Replace with your AWS IoT Policy Name. eg: MyIoTPolicy")

        static let iotPolicyName = "MyIoTPolicy"

        #error("Also update FreeRTOSDemo/Support/awsconfiguration.json with your credentials.")

        static let mqttCustomTopic = "my/custom/topic"
    }
}
