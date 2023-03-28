# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Bullet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Bullet
  pod 'Alamofire', '~> 5.2'
  pod 'SDWebImage', '~> 5.0'
  pod 'IQKeyboardManagerSwift'
  pod 'Heimdallr'
  pod 'SwiftTheme'
  pod 'Firebase/Core', '~> 7.7.0'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
#  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Google-Mobile-Ads-SDK', '~> 7.68.0'
#  pod 'Google-Mobile-Ads-SDK'
  pod 'GoogleSignIn'
  pod 'ReachabilitySwift'
  pod 'FlexiblePageControl'
#  pod 'Auth0'
  pod 'PageControls'
  pod 'SwiftySound'
  pod 'Mute'
  pod 'SwiftyOnboard'
  pod 'SwiftRater'
  pod 'Toast-Swift'
  pod 'AppsFlyerFramework'
  pod 'SwiftyGif'
  pod 'PlayerKit'
  pod 'ActiveLabel'
  pod 'Firebase/DynamicLinks'
  pod 'LoadingShimmer'
#  pod 'SkeletonView'
  pod 'SteviaLayout'
  pod 'PryntTrimmerView'
  pod 'TagListView', '~> 1.0'
  pod 'NVActivityIndicatorView'
  pod 'OTPFieldView'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBAudienceNetwork'
  pod 'FBSDKShareKit'
#  pod 'Hero'
  pod 'DataCache'
#  pod 'SnapSDK'
  pod 'QCropper'
  pod 'NicoProgress'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod "ImageSlideshow/SDWebImage"
  pod 'SideMenu'
  pod 'PanModal'
  pod 'UIImageViewAlignedSwift'
#  pod 'AlignedCollectionViewFlowLayout'
  pod 'MediaWatermark'
#  pod 'ChartboostSDK'
  pod 'AlignedCollectionViewFlowLayout'
#  pod 'GSPlayer'
#  pod 'lottie-ios'
  pod 'Skeleton'
  pod 'SwiftAutoLayout'

  pod 'OneSignalXCFramework', '>= 3.0.0', '< 4.0'
  pod 'GSPlayer'
  pod 'GCDWebServer', '~> 3.5'
  
  target 'BULLET' do
    inherit! :search_paths
  end
  
  target 'Bullet_WidgetExtension' do
    inherit! :search_paths
  end
  
  target 'BulletTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'BulletUITests' do
    # Pods for testing
  end
  
  target 'Service' do
    inherit! :search_paths
    
  end
  
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end

    end
end
