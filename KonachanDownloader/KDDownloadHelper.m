//
//  KDDownloadHelper.m
//  KonachanDownloader
//
//  Created by Cee on 07/06/2015.
//  Copyright (c) 2015 Cee. All rights reserved.
//

#import "KDDownloadHelper.h"
#import "KDImageModel.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "NSString+CeeKit.h"

@implementation KDDownloadHelper

#pragma mark - Public Methods

+ (instancetype)sharedDownloadHelper
{
    static dispatch_once_t once;
    static id _sharedInstance = nil;
    
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)sendRequestWithPageNumber:(NSUInteger)number
{
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    NSURL* URL = [NSURL URLWithString:@"http://konachan.com/post"];
    NSDictionary* URLParams = @{@"page": [NSNumberFormatter localizedStringFromNumber:@(number)
                                                                          numberStyle:NSNumberFormatterNoStyle],};
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            // Success
            NSLog(@"URL Session Task Succeeded: HTTP %ld", ((NSHTTPURLResponse*)response).statusCode);
//            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", responseString);
            [self parseData:data];
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    [task resume];
}

#pragma mark - Private Methods
- (void)parseData:(NSData *)data
{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
    NSArray *tagArray = [[parser body] findChildTags:@"a"];
    NSMutableArray *picArray = [[NSMutableArray alloc] init];
    
    for (HTMLNode *node in tagArray) {
        NSString *classString = [node getAttributeNamed:@"class"];
        if ([classString rangeOfString:@"directlink"].length > 0) {
            KDImageModel *model = [[KDImageModel alloc] init];
            model.imageUrl = [node getAttributeNamed:@"href"];
            NSRange slashRange = [model.imageUrl rangeOfString:@"/" options:NSBackwardsSearch];
            NSUInteger l = slashRange.location;
            model.title = [[model.imageUrl substringWithRange:NSMakeRange(l+1, model.imageUrl.length-l-1)] URLDecodedString];
            [picArray addObject:model];
        }
    }
    
    [self downloadPictureWithModels:picArray];
}

- (void)downloadPictureWithModels:(NSMutableArray *)models;
{
    NSString *downloadsPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for (KDImageModel *model in models) {
        
        NSURL *imageUrl = [NSURL URLWithString:model.imageUrl];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   NSString *directoryPath = [downloadsPath stringByAppendingPathComponent:@"Konachan"];
                                   [data writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", model.title]]
                                             options:NSAtomicWrite
                                               error:&error];
                                   NSLog(@"Download image: %@ Finished", model.title);
                               }];
    }
}

#pragma mark - Utils

static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)
                           ];
    return [NSURL URLWithString:URLString];
}

@end
