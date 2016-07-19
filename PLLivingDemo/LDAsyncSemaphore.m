//
//  LDAsyncSemaphore.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAsyncSemaphore.h"

@interface LDAsyncSemaphore ()
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) BOOL isWaiting;
@property (nonatomic, assign) BOOL didFinished;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@end

@implementation LDAsyncSemaphore

- (instancetype)initWithValue:(NSInteger)value
{
    if (self = [self init]) {
        _value = value;
    }
    return self;
}

- (void)signal
{
    _value--;
    if (_value <= 0 && self.isWaiting) {
        [self _callTarget];
    }
}

- (void)waitWithTarget:(id)target withAction:(SEL)action
{
    self.target = target;
    self.action = action;
    self.isWaiting = YES;
    
    if (_value <= 0) {
        [self _callTarget];
    }
}

- (void)_callTarget
{
    if (!self.didFinished) {
        __strong id strongTarget = self.target;
        if ([strongTarget respondsToSelector:self.action]) {
            [strongTarget performSelector:self.action];
        }
        self.didFinished = YES;
    }
}

@end
