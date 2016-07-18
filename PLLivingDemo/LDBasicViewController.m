//
//  LDBasicViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDBasicViewController.h"

#define kPopupAnimationDuration 0.5

@interface LDBasicViewController ()
@property (nonatomic, assign) BOOL maskAllTouchEvents;
@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
@end

@interface _LDBasicView : UIView
@property (nonatomic, weak) LDBasicViewController *basicViewController;
- (instancetype)initWithBasicViewController:(LDBasicViewController *)basicViewController;
@end

@implementation LDBasicViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.viewControllers = [[NSMutableArray<UIViewController *> alloc] init];
    }
    return self;
}

- (void)loadView
{
    self.view = [[_LDBasicView alloc] initWithBasicViewController:self];
}

- (void)popupViewController:(UIViewController * __nonnull)viewController
                   animated:(BOOL)animatedFlag
                 completion:(void (^ __nullable)(void))completion
{
    if (![self.viewControllers containsObject:viewController]) {
        [self.viewControllers addObject:viewController];
        UIView *view = viewController.view;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
        CGRect targetFrame = self.view.bounds;
        
        if (animatedFlag) {
            _maskAllTouchEvents = YES;
            view.frame = CGRectMake(0, targetFrame.size.height,
                                    targetFrame.size.width, targetFrame.size.height);
            [UIView animateWithDuration:kPopupAnimationDuration animations:^{
                view.frame = targetFrame;
                
            } completion:^(BOOL finished) {
                _maskAllTouchEvents = NO;
                if (!finished) {
                    view.frame = targetFrame;
                }
                if (completion) {
                    completion();
                }
            }];
        } else {
            view.frame = targetFrame;
            if (completion) {
                completion();
            }
        }
    }
}

- (void)removeViewController:(UIViewController * __nonnull)viewController
                    animated:(BOOL)animatedFlag
                  completion:(void (^ __nullable)(void))completion
{
    if ([self.viewControllers containsObject:viewController]) {
        [self.viewControllers removeObject:viewController];
        UIView *view = viewController.view;
        
        if (animatedFlag) {
            _maskAllTouchEvents = YES;
            [UIView animateWithDuration:kPopupAnimationDuration animations:^{
                CGRect targetFrame = view.frame;
                targetFrame.origin.y = targetFrame.size.height;
                view.frame = targetFrame;
                
            } completion:^(BOOL finished) {
                _maskAllTouchEvents = NO;
                [view removeFromSuperview];
                if (completion) {
                    completion();
                }
            }];
        } else {
            [view removeFromSuperview];
            if (completion) {
                completion();
            }
        }
    }
}

@end

@implementation _LDBasicView

- (instancetype)initWithBasicViewController:(LDBasicViewController *)basicViewController
{
    if (self = [super init]) {
        self.basicViewController = basicViewController;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 在播动画期间，全程无法响应任何 touch。
    if (self.basicViewController.maskAllTouchEvents) {
        return nil;
    }
    // 只有最上层的 view controller 可以被 touch 到。
    // 除此之外的其他 view controller 即便不小心漏一部分，那一部分也无法响应 touch。
    UIViewController *viewControllerEnableTouch = self.basicViewController.viewControllers.lastObject;
    if (viewControllerEnableTouch) {
        CGPoint subPoint = [viewControllerEnableTouch.view convertPoint:point fromView:self];
        return [viewControllerEnableTouch.view hitTest:subPoint withEvent:event];
    }
    return nil;
}

- (void)layoutSubviews
{
    for (UIView *subview in self.subviews) {
        subview.frame = self.bounds;
    }
    [super layoutSubviews];
}

@end

@implementation UIViewController (LDBasicViewController)

- (LDBasicViewController *)basicViewController
{
    UIView *view = self.view;
    while (view) {
        if ([view isKindOfClass:[_LDBasicView class]]) {
            return ((_LDBasicView *) view).basicViewController;
        }
        view = view.superview;
    }
    return nil;
}

@end

@implementation UIWindow (LDBasicViewController)

- (LDBasicViewController *)basicViewController
{
    if ([self.rootViewController isKindOfClass:[LDBasicViewController class]]) {
        return (LDBasicViewController *) self.rootViewController;
    }
    return nil;
}

@end
