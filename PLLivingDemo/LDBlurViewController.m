//
//  LDBlurViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDBlurViewController.h"
#import "LDViewConstraintsStateManager.h"

typedef enum {
    BackgroundState_Fix,
    BackgroundState_Float
} BackgroundState;

@implementation LDBlurViewController
{
    UIVisualEffectView *_blurBackgroundView;
    LDViewConstraintsStateManager *_constraints;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _constraints = [[LDViewConstraintsStateManager alloc] init];
    
    _blurBackgroundView = ({
        UIVisualEffectView *view = [[UIVisualEffectView alloc] init];
        __weak typeof(self) weakSelf = self;
        [_constraints addState:@(BackgroundState_Fix) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:view makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(weakSelf.view);
            }];
        }];
        [_constraints addState:@(BackgroundState_Float) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:view makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                // No Constraints.
            }];
        }];
        _constraints.state = @(BackgroundState_Float);
        
        view;
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view.superview insertSubview:_blurBackgroundView belowSubview:self.view];
    CGRect frame = self.view.superview.bounds;
    _blurBackgroundView.frame = frame;
    
    switch (self.presentOrientation) {
        case LDBlurViewControllerPresentOrientation_FromTop:
            frame.origin.y = -frame.size.height;
            break;
            
        case LDBlurViewControllerPresentOrientation_FromBottom:
            frame.origin.y = frame.size.height;
            break;
            
        case LDBlurViewControllerPresentOrientation_FromLeft:
            frame.origin.x = -frame.size.width;
            
            
        case LDBlurViewControllerPresentOrientation_FromRight:
            frame.origin.x = frame.size.width;
            break;
    }
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.75 animations:^{
        _blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.view.frame = self.view.superview.bounds;
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_blurBackgroundView removeFromSuperview];
}

@end
