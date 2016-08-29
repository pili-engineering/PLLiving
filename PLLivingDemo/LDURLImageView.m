//
//  LDURLImage.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/16.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDURLImageView.h"

@interface LDURLImageView ()
@property (nonatomic, strong) NSString *defaultImageName;
@end

@implementation LDURLImageView

- (instancetype)initWithDefaultImageName:(NSString *)defaultImageName
{
    if (self = [self init]) {
        _defaultImageName = defaultImageName;
        self.image = [UIImage imageNamed:defaultImageName];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url withDefaultImageName:(NSString *)defaultImageName
{
    if (self = [self initWithDefaultImageName:defaultImageName]) {
        _url = url;
        [self _loadFromURL];
    }
    return self;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    self.image = [UIImage imageNamed:_defaultImageName];
    [self _loadFromURL];
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
