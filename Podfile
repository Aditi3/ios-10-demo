use_frameworks!

target 'demo10' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK'
end

target 'NotificationService' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['AppEx']
end

target 'NotificationContent' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['AppEx']
    pod 'MapboxStatic.swift', :git => 'https://github.com/mapbox/MapboxStatic.swift.git', :tag => 'v0.6.0'
end

target 'ShareExtension' do
    platform :ios, '10.0'
    pod 'CleverTap-iOS-SDK', :subspecs => ['AppEx']
end

target 'WatchApp Extension' do
    platform :watchos, '3.0'
    pod 'CleverTapWatchOS'
end
