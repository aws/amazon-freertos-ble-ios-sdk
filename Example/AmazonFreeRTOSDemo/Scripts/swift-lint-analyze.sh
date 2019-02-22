xcodebuild -workspace AmazonFreeRTOSDemo.xcworkspace -scheme AmazonFreeRTOSDemo > xcodebuild.log
./Pods/SwiftLint/swiftlint analyze --compiler-log-path ./xcodebuild.log