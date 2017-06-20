
Pod::Spec.new do |s|

  s.name         = "LRLPhotoBrowser"
  s.version      = "1.0.2"
  s.summary      = "A simple iOS photo and video browser"
  s.license      = "MIT"
  s.description  = <<-DESC
                  LRLPhotoBrowser can display one or more images or videos by providing either UIImage
                  objects, image name, or web images/videos.
                  The photo browser handles the downloading and caching of photos from the web seamlessly.
                  Photos can be zoomed and panned.
                   DESC

  s.homepage     = "https://github.com/codeWorm2015/LRLPhotoBrowser"
  s.author             = { "codeWorm" => "codeWorm@foxmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/codeWorm2015/LRLPhotoBrowser.git", :tag => "1.0.2" }
  s.source_files  = "Sources/*.{swift}"
  s.resources = "Sources/*.{png,xib,nib,bundle}"
  s.exclude_files = "Classes/Exclude"

  s.dependency 'Kingfisher', '~> 3.10.2'
  s.dependency 'SnapKit', '~> 3.2.0'
  s.dependency 'MBProgressHUD', '~> 1.0.0'  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
  `echo "3.0" > .swift-version`
end
