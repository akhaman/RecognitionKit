Pod::Spec.new do |s|
  s.name             = 'RecognitionKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of RecognitionKit.'
  s.description      =  'description'
  
  s.homepage         = 'https://github.com/akhaman/RecognitionKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'akhaman' => 'akhaman@yandex.ru' }
  s.source           = { :git => 'https://github.com/akhaman/RecognitionKit.git', :tag => s.version.to_s }
 
  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = "Development/#{s.name}/Sources/**/*.swift"
  
  # s.resource_bundles = {
  #    "#{s.name}Resources" => ["Development/#{s.name}/Resources/**/*.{strings}"]
  # }

  s.pod_target_xcconfig = { 
		'CODE_SIGN_IDENTITY' => '' 
	}

  s.test_spec 'UnitTests' do |test_spec| 
    test_spec.source_files = "Development/#{s.name}/UnitTests/**/*.swift"
  end 
end
