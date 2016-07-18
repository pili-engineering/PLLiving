//
//  LDBasicViewController.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDBasicViewController : UIViewController

- (void)popupViewController:(UIViewController * __nonnull)viewController
                   animated:(BOOL)animatedFlag
                 completion:(void (^ __nullable)(void))completion;
- (void)removeViewController:(UIViewController * __nonnull)viewController
                    animated:(BOOL)animatedFlag
                  completion:(void (^ __nullable)(void))completion;

@end

@interface UIViewController (LDBasicViewController)

- (LDBasicViewController * __nullable)basicViewController;

@end

@interface UIWindow (LDBasicViewController)

- (LDBasicViewController * __nullable)basicViewController;

@end