//
//  LDLivingConfiguration.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/29.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLivingConfiguration.h"

@interface LDLivingConfiguration ()
@property (nonatomic, strong) NSDictionary *configurationDictionary;
@end

@implementation LDLivingConfiguration

static LDLivingConfiguration *_instance;

+ (void)initialize
{
    _instance = [[LDLivingConfiguration alloc] init];
}

+ (instancetype)sharedLivingConfiguration
{
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _configurationDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"living" ofType:@"plist"]];
        
    }
    return self;
}

- (void)setupAllConfiguration
{
    _chatRoomWebsocketURL = self.configurationDictionary[@"ChatRoomWebsocketURL"];
    _httpServerURL = self.configurationDictionary[@"HttpServerURL"];
    
    NSString *wechatAppID = self.configurationDictionary[@"WechatAppID"];
    _canUseWechat = [WXApi registerApp:wechatAppID withDescription:@"LIVING 1.0"] &&
    [WXApi isWXAppSupportApi] && [WXApi isWXAppInstalled];
}

@end
