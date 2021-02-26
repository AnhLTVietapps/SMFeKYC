Pod::Spec.new do |s|

  s.name = 'SMFeKYC'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Your frameworks'
  s.authors = 'AnhLTVietapps'
  s.source = { :git => 'https://github.com/AnhLTVietapps/SMFeKYC.git', :branch => "main" }
  s.dependency 'Alamofire',  '~> 5.2'
  s.dependency 'SwiftTryCatch', '~> 1.0.0'
  s.dependency 'JumioMobileSDK/Netverify', '~>3.8.0'
  s.dependency 'JumioMobileSDK/NetverifyBase', '~>3.8.0'
  s.dependency 'JumioMobileSDK/NetverifyNFC', '~>3.8.0'
  s.dependency 'JumioMobileSDK/NetverifyBarcode', '~>3.8.0'
  s.dependency 'JumioMobileSDK/NetverifyFace+iProov', '~>3.8.0'
  s.dependency 'JumioMobileSDK/NetverifyFace+Zoom', '~>3.8.0' 

  s.ios.deployment_target = '12'

  s.swift_versions = ['5.3']

  s.source_files = 'SMFeKYC/*.swift'


end