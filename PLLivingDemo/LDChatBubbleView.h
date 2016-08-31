//
//  LDChatBubbleView.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LDChatBubbleViewIdentifer @"LDChatBubbleViewIdentifer"

@class LDChatItem;

@interface LDChatBubbleView : UITableViewCell

- (void)resetViewWith:(LDChatItem *)chatItem;

@end
