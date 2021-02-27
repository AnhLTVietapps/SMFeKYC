Pod::Spec.new do |s|

  s.name = 'SMFeKYC'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Your frameworks'
  s.authors = 'AnhLTVietapps'
  s.homepage = 'https://github.com/AnhLTVietapps'
  s.source = { :git => "https://github.com/AnhLTVietapps/SMFeKYC.git", :branch => "main" }
  s.dependency 'Alamofire',  '5.4.1'
  s.dependency 'SwiftTryCatch'
  s.dependency 'JumioMobileSDK', '3.7.2'

  s.ios.deployment_target = '11'

  s.swift_versions = ['5.3']

  s.vendored_frameworks = ['SMFeKYC.xcframework']


end