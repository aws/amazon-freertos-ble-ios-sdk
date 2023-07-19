# ![image](https://user-images.githubusercontent.com/56273942/202568467-0ee721bb-1424-4efd-88fc-31b4f2a59dc6.png) DEPRECATED

## Announcement:
As of July 31st, 2023, this repository is deprecated. The contents of this repository will remain available but we will no longer provide updates nor accept new contributions and pull requests. We recommend instead that you start [here](https://docs.amplify.aws/start/q/integration/ios/) for creating interactions between an iOS device and AWS. For Bluetooth Low Energy APIs we recommend you start [here](https://developer.apple.com/bluetooth/).

Since the initial release of this package, several new iOS versions have been released bringing with them enhanced security and usability. AWS Amplify has also [released dozens of later versions](https://github.com/aws-amplify/aws-sdk-ios/releases) of the [AWS SDK](https://github.com/aws-amplify/aws-sdk-ios) with many new features and bug fixes.

The amazon-freertos-ble-ios-sdk is being deprecated to remove an example built on outdated code.

Have more questions? Post them in the [FreeRTOS forum](https://forums.freertos.org/).

# iOS SDK for FreeRTOS Bluetooth Devices

[![CocoaPods Version](https://img.shields.io/cocoapods/v/AmazonFreeRTOS.svg?style=flat)](https://cocoapods.org/pods/AmazonFreeRTOS)
[![License](https://img.shields.io/cocoapods/l/AmazonFreeRTOS.svg?style=flat)](https://cocoapods.org/pods/AmazonFreeRTOS)
[![Platform](https://img.shields.io/cocoapods/p/AmazonFreeRTOS.svg?style=flat)](https://cocoapods.org/pods/AmazonFreeRTOS)
[![Build Status](https://travis-ci.org/aws/amazon-freertos-ble-ios-sdk.svg?branch=master)](https://travis-ci.org/aws/amazon-freertos-ble-ios-sdk)

## Introduction

Using the iOS SDK for FreeRTOS Bluetooth Devices, you can create mobile applications that do the following:

- Scan for and connect to nearby BLE devices running FreeRTOS

- Provision Wi-Fi networks for a BLE device running FreeRTOS

- Act as a proxy for transmitting MQTT messages between a device running FreeRTOS and the AWS IoT cloud

## Setting Up the SDK

**To install the iOS SDK for FreeRTOS Bluetooth Devices**

1. Install CocoaPods:
```ruby
$ gem install cocoapods
$ pod setup
```

**Note** 

You might need to use sudo to install CocoaPods.

2. Install the SDK with CocoaPods (In Podfile):

**Newer version of the freertos firmware use CBOR encoding, please use:**

```ruby
pod 'AmazonFreeRTOS'
```

**Older version of the freertos firmware use JSON encoding, please use:**

```ruby
pod 'AmazonFreeRTOS', :git => 'https://github.com/aws/amazon-freertos-ble-ios-sdk.git', :tag => '0.9.4'
```

**For FreeRTOS**

https://github.com/aws/amazon-freertos release 201906.00_Major and after


## Contents

All main functions are defined in 

[AmazonFreeRTOSManager.swift](AmazonFreeRTOS/AmazonFreeRTOSManager.swift)

[AmazonFreeRTOSDevice.swift](AmazonFreeRTOS/AmazonFreeRTOSDevice.swift)

These functions include:

## AmazonFreeRTOSManager

### BLE Helper Functions

The SDK includes some functions that help you perform BLE operations with Amazon FreeRTOS devices:

```swift
// Start scan for FreeRTOS devices.
startScanForDevices()

// Stop scan for FreeRTOS devices.
stopScanForDevices()

//  Disconnect. Clear all contexts. Scan for FreeRTOS devices.
rescanForDevices()
```

## AmazonFreeRTOSDevice

### BLE Helper Functions

The device ble options:

```swift
// Connect to the FreeRTOS device.
connect(reconnect: Bool, certificateId: String? = nil, credentialsProvider: AWSCredentialsProvider? = nil)

// Disconnect from the FreeRTOS device.
disconnect()
```

### MQTT Proxy Service

MQTT proxy service start automatically

### Network Config Service

The network configuration service configures the Wi-Fi network of the FreeRTOS Device. Its functions include:

```swift
listNetwork(_ listNetworkReq: ListNetworkReq)
saveNetwork(_ saveNetworkReq: SaveNetworkReq)
editNetwork(_ editNetworkReq: EditNetworkReq)
deleteNetwork(_ deleteNetworkReq: DeleteNetworkReq)
```
## Documentation

https://aws.github.io/amazon-freertos-ble-ios-sdk/

## Demo Application

The SDK includes a demo application that demonstrates some of the main features of the SDK. You can find the demo in [Example/AmazonFreeRTOSDemo](Example/AmazonFreeRTOSDemo).

## License

This library is licensed under the Apache 2.0 License. 
