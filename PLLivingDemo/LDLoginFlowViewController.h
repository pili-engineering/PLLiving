//
//  LDLoginFlowViewController.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/28.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LDLoginFlowViewController;

@protocol LDLoginFlowViewControllerDelegate <NSObject>

- (void)flowViewControllerComplete:(LDLoginFlowViewController *)flowViewController;

@end

@interface LDLoginFlowViewController : UIViewController

@property (nonatomic, weak) id<LDLoginFlowViewControllerDelegate> delegate;

+ (instancetype)loginFlowViewController;

@end
