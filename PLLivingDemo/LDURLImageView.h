//
//  LDURLImage.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/16.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDURLImageView : UIImageView

@property (nonatomic, readonly) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url withDefaultImageName:(NSString *)defaultImageName;

@end
