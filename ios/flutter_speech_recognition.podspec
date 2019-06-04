#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_speech_recognition'
  s.version          = '0.0.1'
  s.summary          = 'An on-device Flutter Speech Recognition plugin'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/rishab2113/flutter_speech_recognition/tree/master'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rishab Nayak' => 'rishab@bu.edu' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end
