# iOS Demo for Amazon FreeRTOS Bluetooth Devices

iOS Demo for Amazon FreeRTOS Bluetooth Devices.

## Introduction

This Demo App demonstrates some of the features of the iOS SDK for Amazon FreeRTOS Bluetooth devices.

## Authentication

To connect to AWS IoT via MQTT, Cognito setup is required. Amazon Cognito provides authentication, authorization, and user management for your web and mobile apps. It allows the end user of the app to access AWS services such AWS IoT.

**Note:** [AWS Mobile Hub](https://console.aws.amazon.com/mobilehub) can help you set up Cognito user and identity pools quickly if you are staring from scratch.

### Step 1: Create AWS IoT Policy

AWS IoT policies authorize your device to perform AWS IoT operations, such as subscribing or publishing to MQTT topics.
For a step-by-step guide to creating AWS IoT policies from the AWS IoT Console, see [Create an AWS IoT Policy](https://docs.aws.amazon.com/iot/latest/developerguide/create-iot-policy.html). When adding statements to your policy, switch to advanced mode, and paste in following sample policy JSON:

```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "iot:Connect",
            "iot:Publish",
            "iot:Subscribe",
            "iot:Receive",
            "iot:GetThingShadow",
            "iot:UpdateThingShadow",
            "iot:DeleteThingShadow"
         ],
         "Resource":[
            "*"
         ]
      }
   ]
}
```

If you are using the AWS API or SDK, use the [CreatePolicy API](https://docs.aws.amazon.com/iot/latest/apireference/API_CreatePolicy.html) to create the policy, with `policyDocument` as the sample policy JSON defined above. Because the SDK uses Cognito for authentication and not a device certificate, you don't need to attach a policy to a device certificate. Instead, attach the policy to a Cognito identity using the AttachPrincipalPolicy API.


### Step 2: Create Federated Identity Pool

Create a Cognito identity pool to attach to the IoT Policy. Create an authenticated role (or unauthenticated role, if needed). For a step-by-step guide to creating Cognito identity pools, see [Getting Started with Amazon Cognito Identity Pools (Federated Identities)](https://docs.aws.amazon.com/cognito/latest/developerguide/getting-started-with-identity-pools.html).

### Step 3: Create Cognito IAM Role Permissions Policies

Open the IAM console, and choose **Roles** from the navigation pane.  Find and choose your authenticated Cognito identity role. Choose the **Permissions** tab and then choose the existing policy. You need to additionally allow AttachPrincipalPolicy so you can attach the Cognito identity to the right AWS IoT Policy. The policy JSON definition should appear as follows:

```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "iot:AttachPrincipalPolicy",
            "iot:Connect",
            "iot:Publish",
            "iot:Subscribe",
            "iot:Receive",
            "iot:GetThingShadow",
            "iot:UpdateThingShadow",
            "iot:DeleteThingShadow"
         ],
         "Resource":[
            "*"
         ]
      }
   ]
}
```

### Step 4: Create Cognito User Pool

The demo app also uses a Cognito user pool. For a step-by-step guide to setting up a Cognito user pool and linking it with a Cognito federated identity pool, see [Accessing AWS Services Using an Identity Pool After Sign-in](https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-integrating-user-pools-with-identity-pools.html).


## Demo App

To run the demo app, follow these steps:

1. Install cocoapod if not yet installed https://cocoapods.org.

1. In the project root, run ```sudo pod install```.

1. Use Xcode to open the project and change the signing developer account to your own account.

1. Update **FreeRTOSDemo/Amazon/AmazonConstants.swift** with the region and iotPolicyName that you created, and update **FreeRTOSDemo/Support/awsconfiguration.json** with the CognitoIdentity and CognitoUserPool Credentials.

1. Run with the device selected. You might need to add the device to the developer account.


## Examples

The demo app uses the SDK and provides 3 examples:

**MqttProxyViewController.swift**

This example shows how to start and stop the MQTT proxy service that allows MQTT messages from Amazon FreeRTOS device to be passed to AWS IoT.

**NetworkConfigViewController.swift**

This example shows how to use the network config service to configure the Wi-Fi network on the Amazon FreeRTOS device.

**NetworkConfigViewController.swift**

This example shows how to use another GATT(BLE) and MQTT stack with the stack that is included in the Amazon FreeRTOS SDK.

## License

This library is licensed under the Apache 2.0 License. 
