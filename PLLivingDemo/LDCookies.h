//
//  LDCookies.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/8.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDCookies : NSObject

+ (instancetype)sharedCookies;
- (void)revert;
- (void)store;

@end
