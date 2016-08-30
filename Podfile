platform :ios, '10.0'
use_frameworks!

target 'demo10' do
    pod 'CleverTap-iOS-SDK', :path => '../clevertap-ios-sdk/'
end

target 'NotificationService' do
    pod 'CleverTap-iOS-SDK', :path => '../clevertap-ios-sdk/', :subspecs => ['AppExtension']
end

target 'NotificationContent' do
    pod 'CleverTap-iOS-SDK', :path => '../clevertap-ios-sdk/', :subspecs => ['AppExtension']
    pod 'MapboxStatic.swift', :git => 'https://github.com/mapbox/MapboxStatic.swift.git', :tag => 'v0.6.0'
end

target 'ShareExtension' do
    pod 'CleverTap-iOS-SDK', :path => '../clevertap-ios-sdk/', :subspecs => ['AppExtension']
end
