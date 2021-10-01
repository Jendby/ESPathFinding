Pod::Spec.new do |s|
  s.name             = 'ESPathFinding'
  s.version          = '0.0.2'
  s.summary          = 'ESPathFinding'
  s.homepage         = 'https://github.com/Jendby/ESPathFinding'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Eugene Smolyakov" => "jendby@gmail.com" }
  s.source           = { :git => 'https://github.com/Jendby/ESPathFinding.git', :tag => "#{s.version}" }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'ESPathFinding/**/*.{swift}'
  s.frameworks   = 'Foundation', 'UIKit', 'CoreLocation', 'SceneKit', 'Accelerate'
  s.weak_frameworks   = 'ARKit'
  s.requires_arc = true
  s.static_framework = true
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
