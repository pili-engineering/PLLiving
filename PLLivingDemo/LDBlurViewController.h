//
//  LDBlurViewController.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LDBlurViewControllerPresentOrientation_FromTop,
    LDBlurViewControllerPresentOrientation_FromBottom,
    LDBlurViewControllerPresentOrientation_FromLeft,
    LDBlurViewControllerPresentOrientation_FromRight
} LDBlurViewControllerPresentOrientation;

@interface LDBlurViewController : UIViewController

@property (nonatomic, assign) LDBlurViewControllerPresentOrientation presentOrientation;

@end
