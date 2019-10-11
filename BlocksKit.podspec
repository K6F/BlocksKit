Pod::Spec.new do |s|
  s.name                  = 'BlocksKit'
  s.version               = '4.5.0'
  s.license               = 'MIT'
  s.summary               = 'The Objective-C block utilities you always wish you had.'
  s.homepage              = 'https://github.com/K-Be/BlocksKit'
  s.author                = { 'Zachary Waldowski' => 'zach@waldowski.me',
                              'Alexsander Akers'  => 'a2@pnd.mn' }
  s.source                = { git:'https://github.com/K-Be/BlocksKit.git', :tag => "v#{s.version}" }
  s.requires_arc          = true
  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.0'

  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
    ss.source_files = 'BlocksKit/BlocksKit+All.h'
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.dependency 'BlocksKit/Concurrency'
    ss.ios.dependency 'BlocksKit/QuickLook'
    ss.ios.dependency 'BlocksKit/UIKit'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'BlocksKit/BlocksKit.h', 'BlocksKit/BKDefines.h', 'BlocksKit/Core/*.{h,m}', 'BlocksKit/Core/Queue/*.{h,m}', 'BlocksKit/DynamicDelegate/Foundation/*.{h,m}', 'BlocksKit/DynamicDelegate/*.{h,m}'
    ss.watchos.exclude_files = 'BlocksKit/DynamicDelegate/Foundation/NSURLConnection+BlocksKit.{h,m}'
  end

  s.subspec 'DynamicDelegate' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.source_files = 'BlocksKit/DynamicDelegate/*.{h,m}'
  end

  s.subspec 'QuickLook' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.platform = :ios
    ss.source_files = 'BlocksKit/BlocksKit+QuickLook.h', 'BlocksKit/QuickLook/*.{h,m}'
    ss.ios.frameworks = 'QuickLook'
  end

  s.subspec 'UIKit' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.platform = :ios
    ss.source_files = 'BlocksKit/BlocksKit+UIKit.h', 'BlocksKit/UIKit/*.{h,m}'
  end

  s.subspec 'Concurrency' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.source_files = 'BlocksKit/Concurrency/*.{h,m,mm}','BlocksKit/BlocksKit+Concurrency.h' 
    ss.private_header_files = 'BlocksKit/Concurrency/BKLock.h'
  end
end
