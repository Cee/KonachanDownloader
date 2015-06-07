//
//  ViewController.m
//  KonachanDownloader
//
//  Created by Cee on 07/06/2015.
//  Copyright (c) 2015 Cee. All rights reserved.
//

#import "ViewController.h"
#import "KDDownloadHelper.h"

@interface ViewController()
@property (nonatomic, strong) KDDownloadHelper *sharedDownloadHelper;
@property (nonatomic) NSUInteger page;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedDownloadHelper = [KDDownloadHelper sharedDownloadHelper];
    self.page = 1;
    [self downloadPicture];
    NSTimer *downloadTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                              target:self
                                                            selector:@selector(downloadPicture)
                                                            userInfo:nil
                                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:downloadTimer forMode:NSRunLoopCommonModes];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)downloadPicture
{
    NSLog(@"Downloading Page %ld", self.page);
    [self.sharedDownloadHelper sendRequestWithPageNumber:self.page];
    self.page++;
}

@end
