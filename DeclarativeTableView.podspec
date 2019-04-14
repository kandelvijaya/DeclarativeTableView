Pod::Spec.new do |spec|

  spec.name         = "DeclarativeTableView"
  spec.version      = "0.0.3"
  spec.summary      = "Create list easily and declaratively."

  spec.license      = "MIT"

  spec.author             = { "vkandel" => "kandelvijaya@gmail.com" }
  spec.social_media_url   = "https://twitter.com/kandelvijaya"
  spec.homepage           = "https://github.com/kandelvijaya/DeclarativeTableView"

  spec.platform     = :ios
  spec.ios.deployment_target  = "9.0"
  spec.source       = { :git => "https://github.com/kandelvijaya/DeclarativeTableView.git", :tag => "#{spec.version}" }

  spec.source_files  = "DeclarativeTableView/DeclarativeTableView/", "DeclarativeTableView/DeclarativeTableView/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
  spec.dependency "FastDiff"
  spec.dependency "Kekka"

end
