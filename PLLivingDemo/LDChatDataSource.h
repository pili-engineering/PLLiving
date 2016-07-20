//
//  LDChatDataSource.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LDChatItem;

@interface LDChatDataSource : NSObject <UITableViewDataSource>

- (NSUInteger)count;
- (void)addChatItem:(LDChatItem *)chatItem;

@end
