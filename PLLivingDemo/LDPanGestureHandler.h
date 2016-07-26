//
//  LDPanGestureHandler.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/26.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LDPanGestureHandlerOrientation_Up,
    LDPanGestureHandlerOrientation_Down,
    LDPanGestureHandlerOrientation_Left,
    LDPanGestureHandlerOrientation_Right
} LDPanGestureHandlerOrientation;

@interface LDPanGestureHandler : UIPanGestureRecognizer

+ (void)handleView:(UIView *)view orientation:(LDPanGestureHandlerOrientation)orientation
      strengthRate:(CGFloat)strengthRate recognized:(void (^)())recognizedCallback;

@end
