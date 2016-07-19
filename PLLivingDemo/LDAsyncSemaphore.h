//
//  LDAsyncSemaphore.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDAsyncSemaphore : NSObject

- (instancetype)initWithValue:(NSInteger)value;
- (void)signal;
- (void)waitWithTarget:(id)target withAction:(SEL)action;

@end
