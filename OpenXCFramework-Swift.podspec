
Pod::Spec.new do |s|
s.name         = "OpenXCFramework-Swift"
s.version      = '1.2.2'
s.summary      = "OpenXC Framework for vehicle"
s.license      = "MIT"
s.homepage     ="https://github.com/openxc"
s.author       = { "Ranjan kumar sahu" => "kranjan@ford.com" }
s.ios.deployment_target ='8.0'

s.module_name = "OpenXCFramework"
s.platform = "ios"
s.source       = { :git => 'https://github.com/openxc/openxc-ios-framework.git', :tag => s.version}
s.source_files = 'openxc-ios-framework/*.swift'
s.requires_arc = true
s.frameworks   = "Foundation"
end
