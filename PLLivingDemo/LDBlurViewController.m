//
//  LDBlurViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDBlurViewController.h"

@implementation LDBlurViewController
{
    UIVisualEffectView *_blurBackgroundView;
    BOOL _didPlayedAppearAnimation;
    BOOL _didPlayedDisappearAnimation;
}

- (instancetype)initWithPresentOrientation:(LDBlurViewControllerPresentOrientation)presentOrientation
{
    if (self = [self init]) {
        _presentOrientation = presentOrientation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.hidden = YES;
    _blurBackgroundView = [[UIVisualEffectView alloc] init];
    _blurBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)playAppearAnimationWithComplete:(void (^)())complete
{
    if (!_didPlayedAppearAnimation) {
        
        [self.view.superview insertSubview:_blurBackgroundView belowSubview:self.view];
        [_blurBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view.superview);
        }];
        CGRect frame = self.view.superview.bounds;
        _blurBackgroundView.frame = frame;
        self.view.hidden = NO;
        
        [self _resetOrigin:&frame.origin withPresentOrientation:self.presentOrientation];
        self.view.frame = frame;
        
        [UIView animateWithDuration:0.55 animations:^{
            _blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.view.frame = self.view.superview.bounds;
            
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
        _didPlayedAppearAnimation = YES;
    }
}

- (void)playDisappearAnimationWithComplete:(void (^)())complete
{
    if (!_didPlayedDisappearAnimation) {
        
        [_blurBackgroundView addSubview:self.view];
        
        CGRect frame = self.view.frame;
        [self _resetOrigin:&frame.origin withPresentOrientation:self.presentOrientation];
        
        [UIView animateWithDuration:0.55 animations:^{
            _blurBackgroundView.effect = nil;
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            [_blurBackgroundView removeFromSuperview];
            if (complete) {
                complete();
            }
        }];
        _didPlayedDisappearAnimation = YES;
    }
}

- (void)_resetOrigin:(CGPoint *)pOrigin withPresentOrientation:(LDBlurViewControllerPresentOrientation)orinetation
{
    *pOrigin = CGPointZero;
    CGRect frame = self.view.superview.bounds;
    
    switch (orinetation) {
        case LDBlurViewControllerPresentOrientation_FromTop:
            pOrigin->y = -frame.size.height;
            break;
            
        case LDBlurViewControllerPresentOrientation_FromBottom:
            pOrigin->y = frame.size.height;
            break;
            
        case LDBlurViewControllerPresentOrientation_FromLeft:
            pOrigin->x = -frame.size.width;
            break;
            
        case LDBlurViewControllerPresentOrientation_FromRight:
            pOrigin->x = frame.size.width;
            break;
    }
}

@end
