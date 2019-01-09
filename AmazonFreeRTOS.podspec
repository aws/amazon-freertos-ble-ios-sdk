Pod::Spec.new do |s|
  s.name          = "AmazonFreeRTOS"
  s.version       = "0.9.1"
  s.summary       = "Amazon FreeRTOS SDK for iOS."
  s.description   = "The AWS SDK for iOS provides a library, code samples, and documentation for developers to build connected mobile applications using AWS."
  s.homepage      = "https://aws.amazon.com/freertos/"
  s.license       = "Apache License, Version 2.0"
  s.author        = { 'Amazon Web Services' => 'amazonwebservices' }
  s.platform      = :ios, '10.0'
  s.swift_version = "4.2"
  s.source        = { :git => "https://github.com/aws/amazon-freertos-ble-ios-sdk.git", :tag => "0.9.0" }
  s.source_files  = "AmazonFreeRTOS/**/*.{swift,m,h}"
  s.requires_arc  = true
  s.frameworks    = "CoreBluetooth"
  s.dependency "AWSMobileClient", "2.6.35"
  s.dependency "AWSIoT", "2.6.35"
end
