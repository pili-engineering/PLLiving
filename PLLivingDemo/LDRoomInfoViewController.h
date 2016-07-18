//
//  LDRoomInfoViewController.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LDRoomInfoViewControllerDelegate <NSObject>
@optional
- (void)onReciveRoomInfoWithTitle:(NSString *)title;
@end

@interface LDRoomInfoViewController : UIViewController

@property (nonatomic, weak) id<LDRoomInfoViewControllerDelegate> delegate;

@end
