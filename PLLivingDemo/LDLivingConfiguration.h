//
//  LDLivingConfiguration.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/29.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDLivingConfiguration : NSObject

@property (nonatomic, assign, readonly) BOOL canUseWechat;
@property (nonatomic, readonly) NSString *chatRoomWebsocketURL;
@property (nonatomic, readonly) NSString *httpServerURL;
@property (nonatomic, readonly) NSString *imageDomain;

+ (instancetype)sharedLivingConfiguration;
- (void)setupAllConfiguration;

@end
