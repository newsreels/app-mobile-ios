# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Bullet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'Alamofire', '~> 5.2'
  pod 'SDWebImage', '~> 5.0'
  pod 'IQKeyboardManagerSwift'
  pod 'Heimdallr'
  pod 'SwiftTheme'
  pod 'Firebase/Core', '10.20.0'
  pod 'Firebase/Messaging', '10.20.0'
  pod 'Firebase/Crashlytics', '10.20.0'
  pod 'Firebase/Performance', '10.20.0'
  pod 'Firebase/DynamicLinks', '10.20.0'
  pod 'Google-Mobile-Ads-SDK', '~> 10.14.0'
  pod 'GoogleSignIn' , '5.0.2'
  pod 'ReachabilitySwift'
  pod 'FlexiblePageControl'
  pod 'PageControls'
  pod 'SwiftySound'
  pod 'Mute'
  pod 'SwiftyOnboard'
  pod 'SwiftRater' , '2.1.3'
  pod 'Toast-Swift'
  pod 'AppsFlyerFramework'
  pod 'SwiftyGif'
  pod 'PlayerKit' , '2.0.0'
  pod 'ActiveLabel'
  pod 'LoadingShimmer'
  pod 'SteviaLayout'
  pod 'PryntTrimmerView'
  pod 'TagListView', '~> 1.0'
  pod 'NVActivityIndicatorView'
  pod 'OTPFieldView'
  pod 'FBSDKCoreKit', '11.0.1'
  pod 'FBSDKLoginKit' , '11.0.1'
  pod 'FBAudienceNetwork' , '6.12.0'
  pod 'FBSDKShareKit' , '11.0.1'
  pod 'DataCache'
  pod 'QCropper'
  pod 'NicoProgress'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod "ImageSlideshow/SDWebImage"
  pod 'SideMenu'
  pod 'PanModal'
  pod 'UIImageViewAlignedSwift'
  pod 'MediaWatermark'
  pod 'AlignedCollectionViewFlowLayout'
  pod 'Skeleton'
  pod 'SwiftAutoLayout'
  pod 'OneSignalXCFramework', '>= 3.0.0', '< 4.0'
  pod 'GSPlayer'
  pod 'GCDWebServer', '~> 3.5'


target 'Bullet_WidgetExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire', '~> 5.2'

  # Pods for Bullet_WidgetExtension

end


target 'BULLET' do
use_frameworks!
   inherit! :search_paths
   use_frameworks!

  # Pods for Content

end

target 'Content' do
use_frameworks!
   inherit! :search_paths
   use_frameworks!

  # Pods for Content

end

target 'Service' do
use_frameworks!
   inherit! :search_paths
  # Pods for Service

 end
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end

    end
end
