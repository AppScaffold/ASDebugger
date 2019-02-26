#
# Be sure to run `pod lib lint ASDebugger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ASDebugger"
  s.version          = "0.0.9"
  s.summary          = "ASDebugger is a remote debugging toolset for your native iOS app."

  s.description      = <<-DESC
                       Remote debugging network requests, effortlessly Mock Data, Intergrated with iOS easily, without any tooling involved like Charles.
                       DESC

  s.homepage         = "https://github.com/AppScaffold/ASDebugger"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "square" => "square.zhao.wei@gmail.com" }
  s.source           = { :git => "https://github.com/AppScaffold/ASDebugger.git", :tag => s.version }

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.dependency 'SocketRocket', '~> 0.5.1'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |c|
    c.source_files  = 'Pod/Classes/**/*'
    c.public_header_files = "Pod/Classes/**/*.h"
  end
  
end
