//
//  LDUser.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/16.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDUser.h"

@implementation LDUser

static LDUser *_instance;

+ (void)initialize
{
    _instance = [[LDUser alloc] init];
}

+ (instancetype)sharedUser
{
    return _instance;
}

- (void)resetUserName:(NSString *)userName andIconURL:(NSString *)iconURL
{
    _userName = userName;
    _iconURL = iconURL;
}

@end
