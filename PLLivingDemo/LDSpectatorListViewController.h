//
//  LDSpectatorListViewController.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LDBlurViewController.h"

@class LDSpectatorItem;

@interface LDSpectatorListViewController : LDBlurViewController

- (instancetype)initWithSpectators:(NSArray <LDSpectatorItem *> *)spectators;
- (void)close;

@end
