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
@property (nonatomic, strong) void (^block)();
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

- (void)waitWithBlock:(void (^)())block
{
    self.block = block;
    self.isWaiting = YES;
    
    if (_value <= 0) {
        [self _callTarget];
    }
}

- (void)waitWithTarget:(id)target withAction:(SEL)action
{
    __weak id weakTarget = target;
    [self waitWithBlock:^{
        __strong id strongTarget = weakTarget;
        if ([strongTarget respondsToSelector:action]) {
            [strongTarget performSelector:action];
        }
    }];
}

- (void)_callTarget
{
    if (!self.didFinished) {
        if (self.block) {
            self.block();
        }
        self.didFinished = YES;
    }
}

@end
