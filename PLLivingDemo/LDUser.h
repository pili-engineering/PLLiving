//
//  LDUser.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/16.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDUser : NSObject

@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *iconURL;

+ (instancetype)sharedUser;
- (void)resetUserName:(NSString *)userName andIconURL:(NSString *)iconURL;
- (BOOL)hasSetUserInfo;
- (void)loadFromUserDefaults;

@end
