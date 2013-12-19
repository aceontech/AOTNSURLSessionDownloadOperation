//
//  AOTDownloadsViewController.m
//  AOTNSURLDownloadOperationDemo
//
//  Created by Alex Manarpies on 19/12/13.
//  Copyright (c) 2013 Alex Manarpies. All rights reserved.
//

#import "AOTDownloadsViewController.h"
#import <AOTNSURLSessionDownloadOperation.h>
#import <AFNetworking.h>

static NSString *const kCellId = @"Cell";

@interface AOTDownloadsViewController ()
@property (nonatomic,strong) NSMutableArray *downloads;
@property (nonatomic,strong) UIBarButtonItem *downloadButton;
@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@property (nonatomic,strong,readonly) NSFileManager *fileManager;
@property (nonatomic,strong) AFURLSessionManager *sessionManager;
@end

@implementation AOTDownloadsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

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

- (UIBarButtonItem *)downloadButton
{
    if (!_downloadButton) {
        _downloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(downloadButtonTapped:)];
    }
    return _downloadButton;
}

- (NSOperationQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (void)downloadButtonTapped:(UIBarButtonItem *)sender
{
    NSInteger i = 0;
    __weak typeof(self)wself = self;
    for (NSDictionary *download in self.downloads)
    {
        NSOperation *operation = [[AOTNSURLSessionDownloadOperation alloc] initDownloadOperationForURL:download[@"downloadURL"] toBeSavedAtURL:[self fileURLForName:download[@"name"]] usingSessionManager:self.sessionManager completionBlock:^(NSURL *result) {
            
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
        
        [self.downloadQueue addOperation:operation];
        i++;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Downloads", nil);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellId];
    self.navigationItem.rightBarButtonItem = self.downloadButton;
    self.downloads = [@[[@{@"downloadURL": [NSURL URLWithString:@"http://www.podtrac.com/pts/redirect.mp3/twit.cachefly.net/audio/tnt/tnt0901/tnt0901.mp3"],
                           @"name": @"TNT905"} mutableCopy],
                       [@{@"downloadURL": [NSURL URLWithString:@"http://www.podtrac.com/pts/redirect.mp3/twit.cachefly.net/audio/tnt/tnt0896/tnt0896.mp3"],
                         @"name": @"TNT904"} mutableCopy],
                       [@{@"downloadURL": [NSURL URLWithString:@"http://www.podtrac.com/pts/redirect.mp3/twit.cachefly.net/audio/tnt/tnt0891/tnt0891.mp3"],
                         @"name": @"TNT903"} mutableCopy]] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloads count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    NSDictionary *download = self.downloads[indexPath.row];
    
    if ([download valueForKey:@"progress"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%.2f%%)", download[@"name"], [(NSNumber *)download[@"progress"] floatValue] * 100];
    } else if ([download valueForKey:@"error"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (!)", download[@"name"]];
    }else {
        cell.textLabel.text = download[@"name"];
    }
    
    return cell;
}

#pragma mark - Internal

/**
 * Files reside in ~/Documents/Downloads
 * @param episode JPPCDEpisode
 * @returns NSURL*
 */
- (NSURL *)fileURLForName:(NSString *)name
{
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    NSURL *downloadsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Downloads"];
    NSURL *destinationURL = [downloadsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", name]];
    
    if (![self fileExistsAtURL:downloadsDirectoryURL isDirectory:YES]) {
        NSError *error;
        
        // Create directory if it doesn't already exist
        [self.fileManager createDirectoryAtURL:downloadsDirectoryURL withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (!error) {
            // Exclude the downloads directory from iCloud backup
            [downloadsDirectoryURL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
            
            if (error) {
                NSLog(@"Couldn't assign Downloads directory as excluded-from-iCloud-backup!");
            }
        } else {
            NSLog(@"An error occurred while creating downloads directory: %@", error);
        }
    }
    
    return destinationURL;
}

/**
 * Convenience method.
 * @param url NSURL*
 * @param isDirectory BOOL
 */
- (BOOL)fileExistsAtURL:(NSURL *)url isDirectory:(BOOL)isDirectory
{
    return [self.fileManager fileExistsAtPath:[url path] isDirectory:&isDirectory];
}

@end
