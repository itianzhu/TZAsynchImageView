//
//  TZAsynchImageView.h
//  TZImageViewDemo
//
//  Created by TZ on 13-12-13.
//  Copyright (c) 2013年 iTian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZAsynchImageView : UIImageView

@property (nonatomic,retain) NSString *urlString;

- (id)initWithUrlString:(NSString *) urlString frame:(CGRect) frame placeholder:(UIImage*) image;

- (void)setUrlString:(NSString *)urlString placeholder:(UIImage *)image;




@end
