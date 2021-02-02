import AWSCore

struct AmazonConstants {

    struct AWS {

        // #warning("if you do not plan to use the MQTT demo, you can remove these #error.")

        // #error("Replace with your AWS Region. eg: AWSRegionType.USEast2")

        static let region = AWSRegionType.USWest2

        // #error("Replace with your AWS IoT Policy Name. eg: MyIoTPolicy")

        static let iotPolicyName = "IoTPolicyForBLE"

        // #error("Also update FreeRTOSDemo/Support/awsconfiguration.json with your credentials.")

        static let mqttCustomTopic = "my/custom/topic"
    }
}
