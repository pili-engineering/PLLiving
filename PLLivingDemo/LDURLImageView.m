//
//  LDURLImage.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/16.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDURLImageView.h"

@implementation LDURLImageView

- (instancetype)initWithURL:(NSURL *)url withDefaultImageName:(NSString *)defaultImageName
{
    if (self = [self init]) {
        _url = url;
        self.image = [UIImage imageNamed:defaultImageName];
        [self _loadFromURL];
    }
    return self;
}

- (void)_loadFromURL
{
    __weak typeof(self) weakSelf = self;
    NSURL *url = self.url;
    
    NSLog(@"load image from %@", url);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        NSLog(@"finished load image %@", url);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.image = image;
            }
        });
    });
}

@end
