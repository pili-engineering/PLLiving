//
//  LDShareViewController.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/29.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBlurViewController.h"

@class LDRoomItem;

@interface LDShareViewController : LDBlurViewController

- (instancetype)initWithPresentOrientation:(LDBlurViewControllerPresentOrientation)presentOrientation withRoomItem:(LDRoomItem *)roomItem;
- (void)close;

@end
