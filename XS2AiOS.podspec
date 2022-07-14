Pod::Spec.new do |s|
  s.name             = 'XS2AiOS'
  s.version          = '1.7.1'
  s.summary          = 'Native integration of Tink Germany XS2A API for your iOS apps.'

  s.homepage         = 'https://github.com/FinTecSystems/xs2a-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tink Germany GmbH' => 'support@tink-germany.com' }
  s.source           = { :git => 'https://github.com/FinTecSystems/xs2a-ios.git', :tag => s.version.to_s }

  s.dependency		'SwiftyJSON', '5.0.1'
  s.dependency		'NVActivityIndicatorView', '5.1.1'
  s.dependency		'XS2AiOSNetService', '1.0.7'
  s.dependency		'KeychainAccess', '4.2.2'

  s.cocoapods_version = '>= 1.10.0'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.3'

  s.source_files = 'Sources/XS2AiOS/**/*.swift'
  s.resource_bundles = {
	"XS2AiOS" => ['Sources/XS2AiOS/Resources/**/*.{xib,lproj}'],
	"Images" => ['Sources/XS2AiOS/Resources/Images.xcassets']
  }
end
