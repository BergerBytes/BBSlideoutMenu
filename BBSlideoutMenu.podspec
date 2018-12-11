#
# Be sure to run `pod lib lint BBSlideoutMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BBSlideoutMenu"
  s.version          = "0.4.1"
  s.summary          = "A simple 'one line of code' Slideout Menu solution without the need for segues"

  s.description      = <<-DESC "A simple solution for creating great looking slideout menus quickly. By nesting the menu view in the scene dock you can visually edit the menu whilst skipping the need to manage data between segues and view controllers."
                       DESC

  s.homepage         = "http://bergerbytes.io/cocoapods/bbslideoutmenu/"
  # s.screenshots    = "https://bergerbytesco.files.wordpress.com/2016/03/giphy.gif"
  s.license          = 'MIT'
  s.author           = { "Michael Berger" => "contact@bergerbytes.io" }
  s.source           = { :git => "https://github.com/BergerBytes/BBSlideoutMenu.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bergerbytes'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/'
  s.swift_version = '4.2'

end