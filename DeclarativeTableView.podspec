Pod::Spec.new do |spec|

  spec.name         = "DeclarativeTableView"
  spec.version      = "0.0.5"
  spec.summary      = "Create list easily and declaratively."
  spec.swift_version = "4.2"

  spec.license      = "MIT"

  spec.author             = { "vkandel" => "kandelvijaya@gmail.com" }
  spec.social_media_url   = "https://twitter.com/kandelvijaya"
  spec.homepage           = "https://github.com/kandelvijaya/DeclarativeTableView"

  spec.platform     = :ios
  spec.ios.deployment_target  = "11.0"
  spec.source       = { :git => "https://github.com/kandelvijaya/DeclarativeTableView.git", :tag => "#{spec.version}" }

  spec.source_files  = "DeclarativeTableView/DeclarativeTableView/", "DeclarativeTableView/DeclarativeTableView/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
  spec.dependency "FastDiff"
  spec.dependency "Kekka"

end
