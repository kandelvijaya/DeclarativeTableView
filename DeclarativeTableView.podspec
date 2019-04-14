Pod::Spec.new do |spec|

  spec.name         = "DeclarativeTableView"
  spec.version      = "0.0.1"
  spec.summary      = "Create list easily and declaratively."

  spec.license      = "MIT"

  spec.author             = { "vkandel" => "kandelvijaya@gmail.com" }
  spec.social_media_url   = "https://twitter.com/kandelvijaya"
  spec.homepage           = "https://github.com/kandelvijaya/DeclarativeTableView"

  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/kandelvijaya/DeclarativeTableView.git", :tag => "#{spec.version}" }

  spec.source_files  = "DeclarativeTableView/DeclarativeTableView/", "DeclarativeTableView/DeclarativeTableView/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"

end
