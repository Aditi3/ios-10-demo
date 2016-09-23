use_frameworks!

target 'demo10' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['HostWatchOS']
end

target 'NotificationService' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['AppExtension']
end

target 'NotificationContent' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['AppExtension']
    pod 'MapboxStatic.swift', :git => 'https://github.com/mapbox/MapboxStatic.swift.git', :tag => 'v0.6.0'
end

target 'ShareExtension' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['AppExtension']
end

target 'WatchApp Extension' do
    platform :watchos, '3.0'
    pod 'CleverTapWatchOS'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
