Pod::Spec.new do |spec|
  spec.name         = 'FCUUID'
  spec.version      = '1.1.0'
  spec.license      = { :type => 'UNLICENSE' }
  spec.homepage     = 'https://github.com/fabiocaccamo/FCUUID'
  spec.authors      = { 'Fabio Caccamo' => 'fabio.caccamo@gmail.com' }
  spec.summary      = 'iOS UUID / Universally Unique Identifiers library as alternative to UDID and identifierForVendor.'
  spec.source       = { :git => 'https://github.com/fabiocaccamo/FCUUID.git', :tag => '1.1.0' }
  spec.source_files = 'FCUUID/*.{h,m}'
  spec.platform     = :ios, '5.0'
  spec.framework    = 'Foundation', 'UIKit', 'Security'
  spec.requires_arc = true
  spec.dependency 'UICKeyChainStore', '~> 1.0.5'
end
