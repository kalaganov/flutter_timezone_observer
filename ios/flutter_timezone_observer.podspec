#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_timezone_observer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_timezone_observer'
  s.version          = '1.1.0'
  s.summary          = 'Get and observe the device IANA timezone.'
  s.description      = <<-DESC
Get and observe the device's IANA timezone. Includes mixins to automatically sync the timezone when the app resumes.
                       DESC
  s.homepage         = 'https://github.com/kalaganov/flutter_timezone_observer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kalaganov' => 'eugene.kalaganov@aptlifemedia.com' }
  s.source           = { :path => '.' }
  # Point CocoaPods at the same sources used by the Swift package so both
  # build systems share a single source of truth.
  s.source_files = 'flutter_timezone_observer/Sources/flutter_timezone_observer/**/*.swift'
  s.resource_bundles = {'flutter_timezone_observer_privacy' => ['flutter_timezone_observer/Sources/flutter_timezone_observer/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
