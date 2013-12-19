Pod::Spec.new do |s|

  s.name         = "AOTNSURLSessionDownloadOperation"
  s.version      = "0.1.1"
  s.summary      = "NSURLSessionDownloadTask wrapped in NSOperation for use with NSOperationQueue (requires AFNetworking 2)."

  s.description  = <<-DESC
                   AOTNSURLSessionDownloadOperation wraps a NSURLSessionDownloadTask managed by 
					AFNetworking 2 in an NSOperation so it can be managed with a NSOperationQueue.
					This allows you to queue any number of downloads and let the run serially
					(in sequence, by setting operationQueue.maxConcurrentOperationCount = 1) or in 
					parallel (operationQueue.maxConcurrentOperationCount > 1).

					Make sure you have permission to write in the saveURL you provide.

					COMPATIBILITY: iOS 7 and higher (due to availability of NSURLSession)
                   DESC

  s.homepage     = "https://github.com/aceontech/AOTNSURLSessionDownloadOperation"

  s.license      = 'MIT'

  s.author       = { "Alex Manarpies" => "alex@manarpies.com" }

  s.platform     = :ios, '7.0'

  s.source       = { :git => "https://github.com/aceontech/AOTNSURLSessionDownloadOperation.git", :tag => "0.1.1" }

  s.source_files  = 'AOTNSURLSessionDownloadOperation/Classes', 'AOTNSURLSessionDownloadOperation/Classes/**/*.{h,m}'
  s.exclude_files = 'AOTNSURLSessionDownloadOperation/Classes/Exclude'

  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 2.0'

end
