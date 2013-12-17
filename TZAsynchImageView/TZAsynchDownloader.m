//
//  TZAsynchDownloader.m
//  SohoApp
//
//  Created by TZ on 13-12-16.
//  Copyright (c) 2013年 ChongQing MiChong Technology. All rights reserved.
//

#import "TZAsynchDownloader.h"

static TZAsynchDownloader *downloader = nil;

@interface TZAsynchDownloader ()

@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,retain) NSMutableArray *downloadingImageUrlStrings;


@end

@implementation TZAsynchDownloader

- (void)dealloc
{
    self.queue = nil;
    self.downloadingImageUrlStrings = nil;
    self.cache = nil;
    [super dealloc];
}

+ (TZAsynchDownloader*)getInstance
{
    if (downloader) {
        return downloader;
    }
    downloader = [[TZAsynchDownloader alloc] init];
    [TZAsynchDownloader createDir];
    
    if (!downloader.queue) {
        downloader.queue = [[[NSOperationQueue alloc] init] autorelease];
        [downloader.queue setMaxConcurrentOperationCount:2];
    }
    
    if (!downloader.cache) {
        downloader.cache = [[[NSCache alloc] init] autorelease];
        [downloader.cache setTotalCostLimit:1024 * 1024 * 1];
    }
    
    if (!downloader.downloadingImageUrlStrings) {
        downloader.downloadingImageUrlStrings = [NSMutableArray array];
    }
    return downloader;
}

- (void)clearMemoryFiles
{
    [self.cache removeAllObjects];
}

+ (NSString *)legalFileNameString:(NSString *)fileName
{
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    return [[[[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""] componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

+ (UIImage *)loadImageFromDick:(NSString*)urlString
{
    NSString *head = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [[head stringByAppendingPathComponent:@"img"] stringByAppendingPathComponent:[TZAsynchDownloader legalFileNameString:urlString]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"\n从cache文件夹获取图片\nurl:\n%@\npath:\n%@",urlString,filePath);
        [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:filePath error:nil];
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return nil;
}

+ (void)saveImageToDick:(UIImage *)image withUrl:(NSString*)urlString
{
    NSString *head = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [[head stringByAppendingPathComponent:@"img"] stringByAppendingPathComponent:[TZAsynchDownloader legalFileNameString:urlString]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    NSData *data = nil;
    if ([[filePath pathExtension] isEqualToString:@"jpg"]) {
        data = UIImageJPEGRepresentation(image, 1);
    }else if([[filePath pathExtension] isEqualToString:@"png"]){
        data = UIImagePNGRepresentation(image);
    }
    [data writeToFile:filePath atomically:YES];
    NSLog(@"\n储存图片到cache\nurl:\n%@\npath:\n%@",urlString,filePath);
}

- (UIImage*)getImageForUrlString:(NSString *)urlString
{
    UIImage *newImage = [self.cache objectForKey:urlString];
    
    if (!newImage) {
        newImage = [TZAsynchDownloader loadImageFromDick:urlString];
        if (newImage) {
            [self.cache setObject:newImage forKey:urlString];
        }else{
            [self downloadImageFromUrlString:urlString success:nil error:nil];
        }
    }
    return newImage;
}

- (void)downloadImageFromUrlString:(NSString *)urlString success:(SEL) success error:(SEL) error
{

    
    if(![self.downloadingImageUrlStrings containsObject:urlString]){
        [self.downloadingImageUrlStrings addObject:urlString];
        [self.queue addOperationWithBlock:^{
            NSData * data = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]] autorelease];
            UIImage * image = [[[UIImage alloc] initWithData:data] autorelease];
            if (image) {
                [TZAsynchDownloader saveImageToDick:image withUrl:urlString];
                dispatch_async( dispatch_get_main_queue(), ^(void){
                    [self.cache setObject:image forKey:urlString];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadedImage object:nil];
                });
                
            }else{
                NSLog(@"下载图片失败，不存在%@",urlString);
            }
            [self.downloadingImageUrlStrings removeObject:urlString];
        }];
    }else{
        
    }
}

+ (void)clearCacheFilesBefore:(NSDate *)beforeDate
{
    NSString *head = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath = [head stringByAppendingPathComponent:@"img"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filePaths = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSDictionary *dic = nil;
    if (filePaths) {
        for (NSString *fileName in filePaths) {
            NSString *filePath = [[head stringByAppendingPathComponent:@"img"] stringByAppendingPathComponent:fileName];
            dic = [fileManager attributesOfItemAtPath:filePath error:nil];
            NSDate *date = [dic objectForKey: NSFileModificationDate];
            if ([date compare:beforeDate] == NSOrderedAscending) {
                NSError *error;
                [fileManager removeItemAtPath:filePath error:&error];
            }
        }
    }
}

+ (void)clearAllCacheFiles
{
    NSString *head = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath = [head stringByAppendingPathComponent:@"img"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filePaths = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    if (filePaths) {
        for (NSString *filePath in filePaths) {
            NSError *error;
            [fileManager removeItemAtPath:[[head stringByAppendingPathComponent:@"img"] stringByAppendingPathComponent:filePath] error:&error];
        }
    }
}

+ (void)createDir
{
    NSString *head = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath = [head stringByAppendingPathComponent:@"img"];
    BOOL *isDir = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:isDir]) {
        if (!isDir) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

@end
