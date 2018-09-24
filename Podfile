source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
use_frameworks!

target 'FreeRTOSDemo' do
  pod 'Alertift'
  pod 'AWSAuthUI'
  pod 'AWSIoT'
  pod 'AWSMobileClient'
  pod 'AWSUserPoolsSignIn'
  pod 'LicensePlist'
  pod 'SwiftFormat/CLI'
  pod 'SwiftLint'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.1'
        end
    end
end
