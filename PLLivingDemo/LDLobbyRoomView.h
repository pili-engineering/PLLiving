//
//  LDLobbyRoomView.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LDLobbyRoomViewIdentifer @"LDLobbyRoomViewIdentifer"

@class LDRoomItem;

@interface LDLobbyRoomView : UITableViewCell

- (void)resetViewWithRoomItem:(LDRoomItem *)roomItem;

@end
