#
# Be sure to run `pod lib lint BBSlideoutMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BBSlideoutMenu"
  s.version          = "0.2.1"
  s.summary          = "A simple 'one line of code' Slideout Menu solution without the need for segues"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC "A simple solution for creating great looking slideout menus quickly. By nesting the menu view in the scene dock you can visually edit the menu whilst skipping the need to manage data between segues and view controllers."
                       DESC

  s.homepage         = "http://bergerbytes.io/cocoapods/bbslideoutmenu/"
  # s.screenshots    = "https://bergerbytesco.files.wordpress.com/2016/03/giphy.gif"
  s.license          = 'MIT'
  s.author           = { "Michael Berger" => "contact@bergerbytes.co" }
  s.source           = { :git => "https://github.com/BergerBytes/BBSlideoutMenu.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bergerbytes'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/'
  s.resource_bundles = {
    'BBSlideoutMenu' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
