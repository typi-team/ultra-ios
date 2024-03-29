#
# Be sure to run `pod lib lint UltraCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UltraCore'
  s.version          = '0.1.4'
  s.summary          = 'A short description of UltraCore.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'TODO: Add long description of the pod here.'

  s.homepage         = 'https://github.com/rakish.shalkar@gmail.com/UltraCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rakish.shalkar@gmail.com' => 'Rakish.Shalkar' }
  s.source           = { :git => 'git@github.com:typi-team/ultra-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'UltraCore/Classes/**/*'
  s.source_files = 'UltraCore/Classes/Sources/**/*'
  
  s.resource_bundles = {
      'UltraCore' => ['UltraCore/Assets/*.xcassets','UltraCore/Assets/*.lproj','UltraCore/Assets/*.pdf', 'UltraCore/Assets/Assets', 'UltraCore/Assets/*.wav']
  }
  
  s.resources = ['UltraCore/Assets/*.pdf', 'UltraCore/*.png', 'UltraCore/*']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

   s.dependency 'SnapKit'
   s.dependency 'RxSwift'
   s.dependency 'PodAsset'
   s.dependency 'Protobuf'
   s.dependency 'IGListKit'
   s.dependency 'gRPC-Swift'
   s.dependency 'SDWebImage'
   s.dependency 'RealmSwift'
   s.dependency 'RxDataSources'
   s.dependency 'NVActivityIndicatorView'
   s.dependency 'LiveKitClient'
   s.dependency 'CocoaLumberjack/Swift'
   
end
