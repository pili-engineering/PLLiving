//
//  LDChatParser.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LDChatItem;

@interface LDChatParser : NSObject

+ (instancetype)sharedChatParser;
- (LDChatItem *)chatItemWithMessage:(NSString *)message;
- (NSString *)messageJSON:(NSString *)message;

@end
