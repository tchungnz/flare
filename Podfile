# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'
use_frameworks!


target 'Flare' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
#  use_frameworks!

  # Pods for Flare

  pod 'Firebase'
  pod 'Firebase/Messaging'
  pod 'FirebaseAuth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'SwiftyJSON', '3.0.0'
  pod 'EasyTipView', '~> 1.0.2'

  target 'FlareTests' do
    inherit! :search_paths
    use_frameworks!
    pod 'Firebase'
    pod 'Firebase/Messaging'
    pod 'FirebaseAuth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
  end

  target 'FlareUITests' do
    inherit! :search_paths
    use_frameworks!
    pod 'Firebase'
    pod 'Firebase/Messaging'
    pod 'FirebaseAuth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
