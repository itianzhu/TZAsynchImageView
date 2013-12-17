//
//  TZAsynchDownloader.h
//  SohoApp
//
//  Created by TZ on 13-12-16.
//  Copyright (c) 2013年 ChongQing MiChong Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDownloadedImage @"kDownloadedImage"


@interface TZAsynchDownloader : NSObject

@property (nonatomic,retain) NSCache *cache;

+ (TZAsynchDownloader*)getInstance;

- (void)downloadImageFromUrlString:(NSString *)UrlString success:(SEL) success error:(SEL) error;

- (UIImage*)getImageForUrlString:(NSString *)urlString;

+ (NSString *)legalFileNameString:(NSString *)fileName;

+ (void)createDir;

+ (void)clearCacheFilesBefore:(NSDate *)beforeDate;

+ (void)clearAllCacheFiles;

+ (UIImage *)loadImageFromDick:(NSString*)urlString;

+ (void)saveImageToDick:(UIImage *)image withUrl:(NSString*)urlString;

- (void)clearMemoryFiles;

@end
