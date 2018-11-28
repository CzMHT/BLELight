source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

use_frameworks!

inhibit_all_warnings!

target 'BLELight' do

   pod 'SnapKit'
   pod 'MJRefresh'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
            end
        end
    end
end