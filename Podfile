platform :ios, 6.0
pod 'RestKit', '~> 0.20.0rc'

xcodeproj 'src/BlueFeed.xcodeproj'

# Include optional Testing and Search components
pod 'RestKit/Testing', '~> 0.20.0rc'
pod 'RestKit/Search', '~> 0.20.0rc'

# Import Expecta for Testing
target :test do
  link_with :BlueFeedTests
  pod 'Expecta', '0.2.1'
end
