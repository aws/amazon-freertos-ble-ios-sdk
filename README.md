## iOS SDK for Amazon FreeRTOS Bluetooth Devices

iOS SDK for Amazon FreeRTOS Bluetooth Devices

## Introduction

This SDK is used to communicate with the Amazon FreeRTOS Bluetooth Devices, It has 2 main features:

**MQTT Proxy**:  Allows a MQTT client (for example device running AFR), to communicate with AWS MQTT broker through a gateway device (for example Mobile Phone).
**Network Config**:  Allows us to provision the wifi networks for the device.

## Authentication

To connect to the AWS IoT via mqtt, cognito setup is required. Amazon Cognito provides authentication, authorization, and user management for your web and mobile apps, It allows the end user of the app to access the your AWS services such AWS IoT. (https://docs.aws.amazon.com/iot/latest/developerguide/protocols.html#mqtt-ws)

**Step 1 - Create AWS IoT Policy**

AWS IoT policies are used to authorize your device to perform AWS IoT operations, such as subscribing or publishing to MQTT topics.
If your are using the AWS Console, a step by step guide can be found here (https://docs.aws.amazon.com/iot/latest/developerguide/create-iot-policy.html)

> When adding the statements, switch to advanced mode, and put in the sample policy JSON.
> Because we are using cognito and not device cert, we don't need to attach the policy to device cert, instead, we attach it to a cognito identity using the AttachPrincipalPolicy API

If your using the AWS API or SDK, please use the CreatePolicy API (https://docs.aws.amazon.com/iot/latest/apireference/API_CreatePolicy.html).

> policyDocument would be the sample policy JSON.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Connect",
        "iot:Publish",
        "iot:Subscribe",
        "iot:Receive",
        "iot:GetThingShadow",
        "iot:UpdateThingShadow",
        "iot:DeleteThingShadow"
      ],
      "Resource": [
        "arn:aws:iot:us-east-1:123456789012:topicfilter/userid/deviceid/*"
      ]
    }
  ]
}
```
**Step 2 - Create Federated Identity Pool**

Customer needs to create an identity pool that can be attached to the IoT Policy, Customer needs to create an authenticated role (or unauthenticated role if needed, step 3 of the guide) and add the policies below, a step by step guide can be found here (https://docs.aws.amazon.com/cognito/latest/developerguide/getting-started-with-identity-pools.html)

**Step 3 - Create Cognito IAM Role Permissions Policies**

IAM > Roles > cognito auth (or unauth if supported) role > Permissions > Permissions policies. We need to additionally allow AttachPrincipalPolicy so that we can attach the Cognito Identity to the AWS IoT Policy.


```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iot:AttachPrincipalPolicy",
                "iot:Connect",
                "iot:Publish",
                "iot:Subscribe",
                "iot:Receive",
                "iot:GetThingShadow",
                "iot:UpdateThingShadow",
                "iot:DeleteThingShadow"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

## SDK Structure

All main functions are in **AWSAfrManager.swift** these includes:

**BLE Helper**
These are ble helper methods for you to perform ble operations with the Amazon FreeRTOS Devices.

```
startScanForPeripherals()
stopScanForPeripherals()
rescanForPeripherals()
connectPeripheral()
disconnectPeripheral()
```

**Device Info Service**
This service provides basic device related info.

```
gatAfrVersionOfPeripheral(_ peripheral: CBPeripheral)
getBrokerEndpointOfPeripheral(_ peripheral: CBPeripheral)
getMtuOfPeripheral(_ peripheral: CBPeripheral)
```

**Mqtt Proxy Service**
This service provides control to the Mqtt Proxy.

```
// Get the current proxying state. (on/off)
getMqttProxyControlOfPeripheral(_ peripheral: CBPeripheral)
// Turn the proxy on or off
updateMqttProxyControlOfPeripheral(_ peripheral: CBPeripheral, control: Control)
```

**Network Config Service**
This service allows the user to config the wifi network of the Amazon FreeRTOS Device.

```
listNetworkOfPeripheral(_ peripheral: CBPeripheral, listNetworkReq: ListNetworkReq)
saveNetworkToPeripheral(_ peripheral: CBPeripheral, saveNetworkReq: SaveNetworkReq)
editNetworkOfPeripheral(_ peripheral: CBPeripheral, editNetworkReq: EditNetworkReq)
deleteNetworkFromPeripheral(_ peripheral: CBPeripheral, deleteNetworkReq: DeleteNetworkReq)
```

## Demo App

The demo app uses the sdk and provides 3 examples:

**1. MqttProxyViewController.swift**
This example showcases how to start and stop the mqtt proxy service that allows mqtt messages from Amazon FreeRTOS device to be passed to AWS IoT.

**2. NetworkConfigViewController.swift**
This example showcases how to use the network config service to configure the wifi network on the Amazon FreeRTOS device.

**3. NetworkConfigViewController.swift**
This example showcases how to use another GATT(BLE) and MQTT stack along side with the one that's in the AWSAfr SDK

## License

This library is licensed under the Apache 2.0 License. 
