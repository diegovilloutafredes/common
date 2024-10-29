Pod::Spec.new do |s|

s.platform     = :ios
s.ios.deployment_target = '13.0'
s.swift_version = "5"
s.requires_arc = true
s.name         = "Common"
s.summary      = "Set of different classes, protocols, extensions."
s.version      = "1.0.0"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "Diego Villouta Fredes" => "diegov17@gmail.com" }
s.homepage     = "https://https://github.com/diegovilloutafredes/common"
s.source       = { :git => "https://github.com/diegovilloutafredes/common.git", :tag => "#{s.version}" }
s.framework = "UIKit"
s.source_files  = "Common/**/*.{swift}"
end