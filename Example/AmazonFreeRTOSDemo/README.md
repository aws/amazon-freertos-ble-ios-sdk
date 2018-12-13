# iOS SDK for Amazon FreeRTOS Bluetooth Devices: Demo Application

## Introduction

This demo application demonstrates some of the features of the iOS SDK for Amazon FreeRTOS Bluetooth devices.

For information about configuring and using the demo application, see [Amazon FreeRTOS BLE Mobile SDK Demo Application](https://docs.aws.amazon.com/freertos/latest/userguide/ble-demo.html#ble-sdk-app) on docs.aws.amazon.com.

## Contents

The demo application includes 3 example controllers:

**MqttProxyViewController.swift**

This controller starts and stops the MQTT proxy service that allows MQTT messages from Amazon FreeRTOS device to be passed to AWS IoT.

**NetworkConfigViewController.swift**

This controller uses the network config service to configure the Wi-Fi network on the Amazon FreeRTOS device.

**CustomGattMqttViewController.swift**

This controller uses a custom GATT service and MQTT stack with the stack that is included in the Amazon FreeRTOS SDK.

## License

This library is licensed under the Apache 2.0 License. 
