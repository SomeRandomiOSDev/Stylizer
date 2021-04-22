Pod::Spec.new do |s|
  
  s.name         = "Stylizer"
  s.version      = "0.1.0"
  s.summary      = "Extendable class library for parsing string attributes"
  s.description  = <<-DESC
                   A small library that provides an extendable framework and classes for parsing attributes from strings
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/Stylizer"
  s.license      = "MIT"
  s.author       = { "Joe Newton" => "somerandomiosdev@gmail.com" }
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/Stylizer.git", :tag => s.version.to_s }

  s.ios.deployment_target     = '9.0'
  s.macos.deployment_target   = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Stylizer/Extensions/*.swift',
                      'Sources/Stylizer/Stylizer/*.swift'
  end

  s.subspec 'UI' do |ss|
    ss.source_files = 'Sources/Stylizer/UI/*.swift'
    ss.dependency 'Stylizer/Core'
  end

  s.default_subspecs  = 'Core', 'UI'
  s.swift_versions    = ['5.0']
  s.cocoapods_version = '>= 1.7.3'
  
end
