Pod::Spec.new do |s|
  s.name             = 'ReactiveSwiftCoreData'
  s.version          = '0.9.0'
  s.summary          = 'ReactiveSwift wrapper on CoreData'
  s.description      = <<-DESC
Add reactive extension on NSManagedObjectContext to observe context changes.
                       DESC

  s.homepage         = 'https://github.com/marshallxxx/ReactiveSwiftCoreData'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'marshallxxx' => 'nicolaevevghenii@gmail.com' }
  s.source           = { :git => 'https://github.com/marshallxxx/ReactiveSwiftCoreData.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ENicolaev'
  s.ios.deployment_target = '9.3'
  s.source_files = 'ReactiveSwiftCoreData/Classes/**/*'
  
  s.dependency 'ReactiveSwift', '~> 3.1'
end
