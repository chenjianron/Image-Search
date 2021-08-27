source 'http://git.flowever.net/component/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

use_frameworks!

target 'Image_Search' do
  use_frameworks!
  pod 'FMDB'  
  pod 'Toolkit'
#  pod 'SnapKit'
  pod 'Alamofire'
  pod 'AdLib'
  pod 'MarketingHelper', '~> 0.1.4'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
        end
    end
end
