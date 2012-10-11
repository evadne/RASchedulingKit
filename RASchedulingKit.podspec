Pod::Spec.new do |s|
	s.platform     = :ios, '5.0'
	s.name         = "RASchedulingKit"
	s.version      = "0.0.3"
	s.summary      = "Asynchronous programming made easy."
	s.homepage     = "http://github.com/evadne/RASchedulingKit"
	s.author       = { "Evadne Wu" => "ev@radi.ws" }
	s.source       = { :git => "https://github.com/evadne/RASchedulingKit.git", :tag => "0.0.1" }
	s.source_files = 'RASchedulingKit', 'Classes/**/*.{h,m}'
	s.framework  = 'Foundation', 'UIKit'
	s.requires_arc = true
	s.license = {:type => 'public-domain', :text => 'Public domain.' }
end
