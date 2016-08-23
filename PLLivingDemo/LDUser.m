//
//  LDUser.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/16.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDUser.h"
#import "LDUserDefaultsKey.h"

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

- (BOOL)hasSetUserInfo
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLDUserDefaultsKey_User] != nil;
}

- (void)loadFromUserDefaults
{
    NSDictionary *users = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLDUserDefaultsKey_User];
    _userName = users[@"userName"];
    _iconURL = users[@"iconURL"];
}

- (void)resetUserName:(NSString *)userName andIconURL:(NSString *)iconURL
{
    _userName = userName;
    _iconURL = iconURL;
    [[NSUserDefaults standardUserDefaults] setObject:@{@"userName": userName,
                                                       @"iconURL": iconURL
                                                       } forKey:kLDUserDefaultsKey_User];
}

@end
