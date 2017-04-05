Pod::Spec.new do |s|
  s.name             = 'ErrorKing'
  s.version          = '0.2.0'
  s.summary          = 'Swift Lib to make displaying errors and emptyState screens a very easy task'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rockbruno/ErrorKing'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rockbruno' => 'brunorochaesilva@gmail.com' }
  s.source           = { :git => 'https://github.com/rockbruno/ErrorKing.git', :branch => "master", :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/Classes/**/*'
  
  s.resource_bundles = {
    'ErrorKing' => ['Sources/Assets/EKAssets.xcassets']
  }

end
