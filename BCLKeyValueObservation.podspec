#
# Be sure to run `pod lib lint BCLKeyValueObservation.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BCLKeyValueObservation"
  s.version          = "0.1.0"
  s.summary          = "BCLKeyValueObservation is a thin abstraction on top of Apple's KVO system."
  s.description      = <<-DESC
BCLKeyValueObservation is a thin abstraction on top of Apple's KVO system. The goals of BCLKeyValueObservation are:
- Less boiler plate code (good bye observeValueForKeyPath:ofObject:change:context:)
- Improve clarity of functionality (imperiative method names)
- **Not** an excuse to have fun with the runtime
                       DESC
  s.homepage         = "https://github.com/benedictc/BCLKeyValueObservation"
  s.license          = 'MIT'
  s.author           = { "Benedict Cohen" => "ben@benedictcohen.co.uk" }
  s.source           = { :git => "https://github.com/benedictc/BCLKeyValueObservation.git", :tag => "0.1.0" }
  # s.social_media_url = 'https://twitter.com/benedictc'

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = "BCLKeyValueObservation", "BCLKeyValueObservation/**/*.{h,m}"
end
