//
//  AOTRootViewController.m
//  AOTNSURLDownloadOperationDemo
//
//  Created by Alex Manarpies on 19/12/13.
//  Copyright (c) 2013 Alex Manarpies. All rights reserved.
//

#import "AOTRootViewController.h"
#import "AOTDownloadsViewController.h"

@interface AOTRootViewController ()
@property (nonatomic,strong) AOTDownloadsViewController *downloadsViewController;
@end

@implementation AOTRootViewController

- (AOTDownloadsViewController *)downloadsViewController
{
    if (!_downloadsViewController) {
        _downloadsViewController = [[AOTDownloadsViewController alloc] init];
    }
    return _downloadsViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.downloadsViewController];
    [self addChildViewController:navController];
    [self.view addSubview:navController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
