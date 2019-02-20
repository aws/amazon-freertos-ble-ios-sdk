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
pod 'AmazonFreeRTOS', :git => 'https://github.com/aws/amazon-freertos-ble-ios-sdk.git'
```

## Contents

All main functions are defined in [AmazonFreeRTOSManager.swift](AmazonFreeRTOS/AmazonFreeRTOSManager.swift). These functions include:

### BLE Helper Functions

The SDK includes some functions that help you perform BLE operations with Amazon FreeRTOS devices:

```
startScanForPeripherals()
stopScanForPeripherals()
rescanForPeripherals()
connectPeripheral()
disconnectPeripheral()
```

### Device Information Service 

The device information service provides basic device-related information. Its functions include:

```
getAfrVersionOfPeripheral(_ peripheral: CBPeripheral)
getBrokerEndpointOfPeripheral(_ peripheral: CBPeripheral)
getMtuOfPeripheral(_ peripheral: CBPeripheral)
```

### MQTT Proxy Service 

The MQTT proxy service controls the MQTT proxy. Its functions include:

```
getMqttProxyControlOfPeripheral(_ peripheral: CBPeripheral)
updateMqttProxyControlOfPeripheral(_ peripheral: CBPeripheral, mqttProxyControl: MqttProxyControl)
```

### Network Config Service 

The network configuration service configures the Wi-Fi network of the Amazon FreeRTOS Device. Its functions include:

```
listNetworkOfPeripheral(_ peripheral: CBPeripheral, listNetworkReq: ListNetworkReq)
saveNetworkToPeripheral(_ peripheral: CBPeripheral, saveNetworkReq: SaveNetworkReq)
editNetworkOfPeripheral(_ peripheral: CBPeripheral, editNetworkReq: EditNetworkReq)
deleteNetworkFromPeripheral(_ peripheral: CBPeripheral, deleteNetworkReq: DeleteNetworkReq)
```

## Demo Application

The SDK includes a demo application that demonstrates some of the main features of the SDK. You can find the demo in [Example/AmazonFreeRTOSDemo](Example/AmazonFreeRTOSDemo).

## License

This library is licensed under the Apache 2.0 License. 
