# iOS SDK for Amazon FreeRTOS Bluetooth Devices

## Introduction

Using the iOS SDK for Amazon FreeRTOS Bluetooth Devices, you can create mobile applications that do the following:

- Scan for and connect to nearby BLE devices running Amazon FreeRTOS

- Provision Wi-Fi networks for a BLE device running Amazon FreeRTOS

- Act as a proxy for transmitting MQTT messages between a device running Amazon FreeRTOS and the AWS IoT cloud

## Setting Up the SDK

**To install the iOS SDK for Amazon FreeRTOS Bluetooth Devices**

1. Install CocoaPods:
```
$ gem install cocoapods
$ pod setup
```

**Note** 

You might need to use sudo to install CocoaPods.

2. Install the SDK with CocoaPods (In Podfile):

**Older version of the freertos firmware use JSON encoding, please use:**

```
pod 'AmazonFreeRTOS', :git => 'https://github.com/aws/amazon-freertos-ble-ios-sdk.git', :tag => '0.9.4'
```

**Newer version of the freertos firmware use CBOR encoding, please use:**

```
pod 'AmazonFreeRTOS', :git => 'https://github.com/aws/amazon-freertos-ble-ios-sdk.git', :tag => '0.9.8'
```

## Contents

All main functions are defined in 

[AmazonFreeRTOSManager.swift](AmazonFreeRTOS/AmazonFreeRTOSManager.swift)
[AmazonFreeRTOSDevice.swift](AmazonFreeRTOS/AmazonFreeRTOSDevice.swift)

These functions include:

### BLE Helper Functions (AmazonFreeRTOSManager)

The SDK includes some functions that help you perform BLE operations with Amazon FreeRTOS devices:

```
// Start scan for AmazonFreeRTOS devices.
startScanForDevices()

// Stop scan for AmazonFreeRTOS devices.
stopScanForDevices()

//  Disconnect. Clear all contexts. Scan for AmazonFreeRTOS devices.
rescanForDevices()
```

### BLE Helper Functions (AmazonFreeRTOSDevice)

### Device Information Service 

The device ble options:

```
// Connect to the AmazonFreeRTOS device.
connect(reconnect: Bool, certificateId: String? = nil, credentialsProvider: AWSCredentialsProvider? = nil)

// Disconnect from the AmazonFreeRTOS device.
disconnect()
```

### MQTT Proxy Service 

MQTT proxy service start automatically

### Network Config Service 

The network configuration service configures the Wi-Fi network of the Amazon FreeRTOS Device. Its functions include:

```
listNetwork(_ listNetworkReq: ListNetworkReq)
saveNetwork(_ saveNetworkReq: SaveNetworkReq)
editNetwork(_ editNetworkReq: EditNetworkReq)
deleteNetwork(_ deleteNetworkReq: DeleteNetworkReq)
```

## Demo Application

The SDK includes a demo application that demonstrates some of the main features of the SDK. You can find the demo in [Example/AmazonFreeRTOSDemo](Example/AmazonFreeRTOSDemo).

## License

This library is licensed under the Apache 2.0 License. 
