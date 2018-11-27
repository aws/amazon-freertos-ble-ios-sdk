# iOS SDK for Amazon FreeRTOS Bluetooth Devices

iOS SDK for Amazon FreeRTOS Bluetooth Devices.

## Introduction

Use this SDK to communicate with Amazon FreeRTOS Bluetooth Devices. The SDK has two main features:

**MQTT Proxy**

The MQTT Proxy enables an MQTT client, such as a device with Amazon FreeRTOS, to communicate with the AWS MQTT broker through a gateway device, such as a mobile phone.

**Network Config**

The Network Config enables you to provision Wi-Fi networks for a device.

## Setting up

The iOS SDK for Amazon FreeRTOS Bluetooth Devices is available through CocoaPods. To set up CocoaPods, follow the instructions for the AWS Mobile SDK for iOS at https://github.com/aws/aws-sdk-ios#cocoapods.

To install the SDK, use the following:
```
pod 'AmazonFreeRTOS', :git => 'https://github.com/aws/amazon-freertos-ble-ios-sdk.git'
```
## SDK Structure

All main functions are in **AmazonFreeRTOSManager.swift**. These functions include:

### BLE Helper Functions

The SDK includes some functions that help you perform BLE operations with Amazon FreeRTOS devices.

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
gatAfrVersionOfPeripheral(_ peripheral: CBPeripheral)
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

## Demo App

Example/AmazonFreeRTOSDemo

## License

This library is licensed under the Apache 2.0 License. 
