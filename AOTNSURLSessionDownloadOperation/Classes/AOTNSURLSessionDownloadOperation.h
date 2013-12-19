//
//  AOTNSURLSessionDownloadOperation.h
//
//  Created by Alex Manarpies on 19/12/13.
//  Copyright (c) 2013 Alex Manarpies. All rights reserved.
//

@class AFURLSessionManager;

typedef void (^AOTCompletionBlock)(NSURL *result);
typedef void (^AOTProgressBlock)(NSNumber *progress);
typedef void (^AOTErrorBlock)(NSError *error);

/**
 * AOTNSURLSessionDownloadOperation wraps a NSURLSessionDownloadTask managed by 
 * AFNetworking 2 in an NSOperation so it can be managed with a NSOperationQueue.
 * This allows you to queue any number of downloads and let the run serially
 * (in sequence, by setting operationQueue.maxConcurrentOperationCount = 1) or in 
 * parallel (operationQueue.maxConcurrentOperationCount > 1).
 *
 * Make sure you have permission to write in the saveURL you provide.
 *
 * COMPATIBILITY: iOS 7 and higher (due to availability of NSURLSession)
 */
@interface AOTNSURLSessionDownloadOperation : NSOperation

/**
 * Creates a download task to be run on an NSOperationQueue.
 *
 * @param downloadURL NSURL* to download the file from
 * @param saveURL NSURL* to save the file to
 * @param manager AFURLSessionManager* (AFNetworking 2) Session manager to use
 * @param completionBlock AOTCompletionBlock returns the saveURL when the download is complete
 * @param errorBlock AOTErrorBlock returns any errors encountered while downloading the file
 * @param progressBlock AOTProgress reports the progress (0.f - 1.f) as a NSNumber*
 */
- (id)initDownloadOperationForURL:(NSURL *)downloadURL
                   toBeSavedAtURL:(NSURL *)saveURL
              usingSessionManager:(AFURLSessionManager *)manager
                  completionBlock:(AOTCompletionBlock)completionBlock
                       errorBlock:(AOTErrorBlock)errorBlock
                    progressBlock:(AOTProgressBlock)progressBlock;

@end
