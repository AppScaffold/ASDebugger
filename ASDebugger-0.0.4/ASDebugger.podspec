Pod::Spec.new do |s|
  s.name = "ASDebugger"
  s.version = "0.0.4"
  s.summary = "ASDebugger is a remote debugging toolset for your native iOS app."
  s.license = "MIT"
  s.authors = {"square"=>"square.zhao.wei@gmail.com"}
  s.homepage = "https://github.com/AppScaffold/ASDebugger"
  s.description = "Remote debugging network requests, effortlessly Mock Data, Intergrated with iOS easily, without any tooling involved like Charles."
  s.frameworks = "Foundation"
  s.requires_arc = true
  s.source = { :path => '.' }

  s.ios.deployment_target    = '7.0'
  s.ios.vendored_framework   = 'ios/ASDebugger.framework'
end
