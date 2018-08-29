

Pod::Spec.new do |s|
s.name         = "OpenXCFramework-Swift"
s.version      = '2.1.0'
s.summary      = "OpenXC Framework for vehicle"
s.license      = "MIT"
s.homepage     ="https://github.com/openxc"
s.author       = { "Ranjan kumar sahu" => "kranjan@ford.com" }
s.ios.deployment_target ='8.0'

s.module_name = "OpenXCFramework"
s.platform = "ios"
s.source       = { :git => 'https://github.com/openxc/openxc-ios-framework.git', :branch => 'next'}
s.source_files = 'src/*.{h,m,swift}'
s.vendored_libraries = 'src/*.a'
s.requires_arc = true
s.frameworks   = "Foundation"
end
