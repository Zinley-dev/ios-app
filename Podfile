# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Stitchbox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Stitchbox
  pod "Texture", '~> 3.1.0'
  pod "SwiftLint", '~> 0.50.3'
  pod 'RxSwift', '~> 6.5.0'
  pod 'RxCocoa', '~> 6.5.0'
  pod 'Alamofire', '~> 5.6.4'
  pod 'Cache', '~> 5.3.0'
  pod 'ObjectMapper', '~> 3.5'

  pod 'GoogleSignIn', '~> 7.0.0'
  
  # Sendbird SDK
  pod 'SendBirdSDK', '~> 3.1.37'
  pod 'SendBirdUIKit', '~> 2.2.11'
  pod 'SendBirdCalls', '~> 1.9.7'
  
  
  # Image SDK
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'RSKImageCropper'
  pod 'NYTPhotoViewer', '~> 1.1.0'
  pod 'AlamofireImage'
  pod 'PixelSDK'
  # animation note
  pod 'SwiftEntryKit', '1.2.6'
  
  # label custom
  pod "ZSWTappableLabel", "~> 2.0"
  pod "ZSWTaggedString/Swift", "~> 4.0"
  pod 'ActiveLabel'

  pod 'OneSignalXCFramework', '>= 3.0.0', '< 4.0'
  #pod 'GoogleMaps'
  #pod 'GooglePlaces'
  pod 'MarqueeLabel'
  pod 'Sentry'
  pod "SwipeTransition"
  pod "SwipeTransitionAutoSwipeBack"      # if needed
  pod "SwipeTransitionAutoSwipeToDismiss" # if needed
  pod 'SCLAlertView'
  
  target 'StitchboxTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StitchboxUITests' do
    # Pods for testing
  end

  target 'StitchboxUnitTests' do
    inherit! :search_paths
    
  end

end
target 'OneSignalNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 3.0.0', '< 4.0'
end
# caches

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
