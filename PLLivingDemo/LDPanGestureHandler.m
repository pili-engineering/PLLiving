//
//  LDPanGestureHandler.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/26.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDPanGestureHandler.h"

@interface LDPanGestureHandler ()
@property (nonatomic, assign) LDPanGestureHandlerOrientation orientation;
@property (nonatomic, assign) CGFloat strengthRate;
@property (nonatomic, strong) void (^recognizedCallback)();
@end

@implementation LDPanGestureHandler

+ (void)handleView:(UIView *)view orientation:(LDPanGestureHandlerOrientation)orientation
      strengthRate:(CGFloat)strengthRate recognized:(void (^)())recognizedCallback
{
    LDPanGestureHandler *handler = [[LDPanGestureHandler alloc] init];
    handler.orientation = orientation;
    handler.strengthRate = strengthRate;
    handler.recognizedCallback = recognizedCallback;
    [handler addTarget:handler action:@selector(_onRecognizeGesture:)];
    [view addGestureRecognizer:handler];
}

- (void)_onRecognizeGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint displacement = [gestureRecognizer translationInView:gestureRecognizer.view]; // 位移矢量
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view]; //速度矢量
    CGFloat radian = atan2(displacement.y, displacement.x); // 位移的弧度
    CGFloat radius2 = pow(displacement.x, 2) + pow(displacement.y, 2); // 位移的半径平方
    CGFloat speed2 = pow(velocity.x, 2) + pow(velocity.y, 2); // 速率的平方
    
    if (_recognizedCallback && [self _checkRadius2:radius2 andSpeed2:speed2] && [self _checkRadian:radian]) {
        _recognizedCallback();
    }
}

- (BOOL)_checkRadius2:(CGFloat)radius2 andSpeed2:(CGFloat)speed2
{
    return radius2 >= pow(128 * _strengthRate, 2) &&
           speed2 >= pow(600 * _strengthRate, 2);
}

- (BOOL)_checkRadian:(CGFloat)radian
{
    switch (self.orientation) {
        case LDPanGestureHandlerOrientation_Up:
            return (-3*M_PI_4 <= radian && radian <= -M_PI_4);
            
        case LDPanGestureHandlerOrientation_Down:
            return (M_PI_4 <= radian && radian <= 3*M_PI_4);
            
        case LDPanGestureHandlerOrientation_Left:
            return (3*M_PI_4 <= radian || radian <= -3*M_PI_4);
            
        case LDPanGestureHandlerOrientation_Right:
            return (-M_PI_4 <= radian || radian <= M_PI_4);
    }
    return NO;
}

@end
