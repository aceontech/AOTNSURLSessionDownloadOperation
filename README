AOTNSURLSessionDownloadOperation wraps a NSURLSessionDownloadTask managed by AFNetworking 2 in an NSOperation so it can be managed with a NSOperationQueue.
This allows you to queue any number of downloads and let them run serially (in sequence, by setting operationQueue.maxConcurrentOperationCount = 1) or in 
parallel (operationQueue.maxConcurrentOperationCount > 1).

Make sure you have permission to write in the saveURL you provide.

COMPATIBILITY: iOS 7 and higher (due to availability of NSURLSession)

# Example

Unnecessary code omitted for brevity:

```objc
@interface ViewController ()
@property (nonatomic,strong) AFURLSessionManager *sessionManager;
@end

@implementation ViewController

...

// This is the operation queue we'll be using. I'm making it serial by setting its 
// maxConcurrentOperationCount property to 1. Set it to whatever makes sense for your 
// application.
- (NSOperationQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

// This is the session manager. It's created with AFNetworking and takes in a configuration
// object. In this case we're using a background session configuration, so download will
// continue even if the app is moved to the background or is terminated. The code to handle
// the completion this background transfer should reside in your AppDelegate 
// See -application:handleEventsForBackgroundURLSession:completionHandler:
- (AFURLSessionManager *)sessionManager
{
    static AFURLSessionManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.aceontech.BackgroundDownloadSession"];
        mgr = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    });
    
    return mgr;
}

// Imagine this method will be invoked when the user taps the download button.
// We iterate over a collection of downloads and create a NSOperation for each. The queue 
// will start executing once the current method scope ends.
- (void)downloadButtonTapped:(UIBarButtonItem *)sender
{
    NSInteger i = 0;
    __weak typeof(self)wself = self;
    for (NSDictionary *download in self.downloads)
    {
    	// Create an operation by alloc-initting a AOTNSURLSessionDownloadOperation.
    	// Pass it a set of URLS, the AFNetworking sessionmanager, completion block, error
    	// block and status block.
        NSOperation *operation = [[AOTNSURLSessionDownloadOperation alloc] initDownloadOperationForURL:download[@"downloadURL"] 
        																   toBeSavedAtURL:[self fileURLForName:download[@"name"]] 
        																   usingSessionManager:self.sessionManager 
        																   completionBlock:^(NSURL *result) {
            
            NSMutableDictionary *download = wself.downloads[i];
            download[@"complete"] = @(YES);
            [wself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } errorBlock:^(NSError *error) {
            
            NSMutableDictionary *download = wself.downloads[i];
            download[@"error"] = error;
            [wself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } progressBlock:^(NSNumber *progress) {
            
            NSMutableDictionary *download = wself.downloads[i];
            download[@"progress"] = progress;
            [wself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
        // Add it a to the queue to start the downloads
        [self.downloadQueue addOperation:operation];
        i++;
    }
}

@end

```