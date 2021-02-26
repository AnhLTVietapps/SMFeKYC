# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SMFeKYC' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SMFeKYC
  pod 'JumioMobileSDK/Netverify', '~>3.8.0' # Use full Netverify and Authentication functionality
  pod 'JumioMobileSDK/NetverifyBase', '~>3.8.0' # For Fastfill, Netverify basic functionality
  pod 'JumioMobileSDK/NetverifyNFC', '~>3.8.0' # For Fastfill, Netverify functionality with NFC extraction
  pod 'JumioMobileSDK/NetverifyBarcode', '~>3.8.0' # For Fastfill, Netverify functionality with barcode extraction
  pod 'JumioMobileSDK/NetverifyFace+iProov', '~>3.8.0' # For Fastfill, Netverify functionality with identity verification, Authentication
  pod 'JumioMobileSDK/NetverifyFace+Zoom', '~>3.8.0' # For Fastfill, Netverify functionality with identity verification, Authentication

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['iProov', 'Socket.IO-Client-Swift', 'Starscream'].include? target.name
        target.build_configurations.each do |config|
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
      end
    end
  end
  
  pod 'SwiftTryCatch', '~> 0.0'
  pod 'Alamofire', '~> 5.2'
end

