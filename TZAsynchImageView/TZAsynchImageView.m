//
//  TZAsynchImageView.m
//  TZImageViewDemo
//
//  Created by TZ on 13-12-13.
//  Copyright (c) 2013年 iTian. All rights reserved.
//

#import "TZAsynchImageView.h"
#import "TZAsynchDownloader.h"

@interface TZAsynchImageView ()

@end

@implementation TZAsynchImageView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.urlString = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithUrlString:(NSString *)urlString frame:(CGRect)frame placeholder:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.urlString = urlString;
        
        [self setImage:image];
        
        [self dealImage];
        
    }
    return self;
}

- (void)setUrlString:(NSString *)urlString
{
    if (_urlString != urlString) {
        [_urlString release];
        _urlString = [urlString retain];
    }
    [self dealImage];
}

- (void)setUrlString:(NSString *)urlString placeholder:(UIImage *)image
{
    [self setImage:image];
    self.urlString = urlString;
}

- (void)dealImage
{
    if (!self.urlString || self.urlString.length == 0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage) name:kDownloadedImage object:nil];
    UIImage *newImage = [[TZAsynchDownloader getInstance] getImageForUrlString:self.urlString];
    
    if (!newImage) {
        
    }else{
        [self setImage:newImage];
    }
}


- (void)changeImage
{
    if (self.urlString == nil) {
        return;
    }
    UIImage *image = [[TZAsynchDownloader getInstance].cache objectForKey:self.urlString];
    if (image && self.urlString) {
        [self setImage:image];
    }
}

@end
