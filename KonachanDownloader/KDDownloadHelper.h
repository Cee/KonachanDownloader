//
//  KDDownloadHelper.h
//  KonachanDownloader
//
//  Created by Cee on 07/06/2015.
//  Copyright (c) 2015 Cee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDDownloadHelper : NSObject

+ (instancetype)sharedDownloadHelper;
- (void)sendRequestWithPageNumber:(NSUInteger)number;

@end
