//
//  AOTNSURLSessionDownloadOperation.m
//
//  Created by Alex Manarpies on 19/12/13.
//  Copyright (c) 2013 Alex Manarpies. All rights reserved.
//

#import "AOTNSURLSessionDownloadOperation.h"
#import <AFURLSessionManager.h>

@interface AOTNSURLSessionDownloadOperation() {
    AOTCompletionBlock _completionBlock;
    AOTProgressBlock _progressBlock;
    AOTErrorBlock _errorBlock;
    
    // Required NSOperation ivars
    BOOL _executing;
    BOOL _finished;
}

@property (nonatomic,strong) AFURLSessionManager *sessionManager;
@property (nonatomic,strong) NSURL *downloadURL;
@property (nonatomic,strong) NSURL *saveURL;
@end

@implementation AOTNSURLSessionDownloadOperation

- (id)initDownloadOperationForURL:(NSURL *)downloadURL
                   toBeSavedAtURL:(NSURL *)saveURL
              usingSessionManager:(AFURLSessionManager *)manager
                  completionBlock:(AOTCompletionBlock)completionBlock
                       errorBlock:(AOTErrorBlock)errorBlock
                    progressBlock:(AOTProgressBlock)progressBlock
{
    self = [super init];
    if (self)
    {
        self.downloadURL = downloadURL;
        self.saveURL = saveURL;
        self.sessionManager = manager;
        
        _completionBlock = [completionBlock copy];
        _errorBlock = [errorBlock copy];
        _progressBlock = [progressBlock copy];
    }
    return self;
}

/**
 * Flags this operation as 'done'.
 */
- (void)done
{
    [self setExecuting:NO];
    [self setFinished:YES];
}

#pragma mark - NSOperation (required overrides)

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isExecuting
{
    return _executing;
}

/**
 * Sets the operation to 'executing' state.
 * Fires the required KVO notifcations.
 */
- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

/**
 * Sets the operation to 'finished' state.
 * Fires the required KVO notifications.
 */
- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

/**
 * Initiate the download and listen for the appropriate progress, error and completiong
 * events.
 */
- (void)main
{
    // The progress var will hold the download progress by reference
    NSProgress *progress;
    
    // Build a regular request to initate the download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.downloadURL];
    
    // Create the download task
    __weak typeof(self)wself = self;
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return wself.saveURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        [progress removeObserver:wself forKeyPath:@"fractionCompleted"];
        
        if (error) {
            // Something went wrong, transparently report error
            if (_errorBlock) {
                _errorBlock(error);
            }
        } else {
            // Download complete, report back with the saveURL
            if (_completionBlock) {
                _completionBlock(wself.saveURL);
            }
        }
        
        // Notify queue that this operation is done
        // (in both error and success case)
        [wself done];
    }];
    
    // Use KVO to observe the progress reported by the fractionCompleted property
    // See -observeValueForKeyPath:ofObject:change:context:
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    // Explicitly start the task; all tasks start in suspended state
    [task resume];
}

/**
 * Allow concurrent execution if desired.
 */
- (BOOL)isConcurrent
{
    return YES;
}

/**
 * Called when the operation is about to be started.
 * Checks current state and starts the -main method.
 */
- (void)start
{
    if( [self isFinished] || [self isCancelled] ) { [self done]; return; }
    [self setExecuting:YES];
    
    [self main];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // The fractionCompleted KVO event comes in each time notable progress is made
    // while writing the file to storage
    if ([keyPath isEqualToString:@"fractionCompleted"])
    {
        NSProgress *progress = (NSProgress *)object;
        
        if (_progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                _progressBlock(@(progress.fractionCompleted));
            });
        }
    }
}

@end
