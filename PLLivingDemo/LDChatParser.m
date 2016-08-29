//
//  LDChatParser.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDChatParser.h"
#import "LDChatItem.h"
#import "LDUser.h"

@implementation LDChatParser

static LDChatParser *_instance;

+ (void)initialize
{
    _instance = [[LDChatParser alloc] init];
}

+ (instancetype)sharedChatParser
{
    return _instance;
}

- (LDChatItem *)chatItemWithMessage:(NSString *)message
{
    NSDictionary *messageJSON = [self _extractJSONWithMessage:message];
    LDChatItem *chatItem = nil;
    
    if (messageJSON && [@"chat" isEqualToString:messageJSON[@"Command"]]) {
        chatItem = [[LDChatItem alloc] init];
        chatItem.username = messageJSON[@"UserName"];
        chatItem.message = messageJSON[@"Message"];
        chatItem.iconURL = messageJSON[@"IconURL"];
    }
    return chatItem;
}

- (NSString *)messageJSON:(NSString *)message
{
    NSDictionary *messageJSON = @{@"UserName": [LDUser sharedUser].userName,
                                  @"IconURL": [LDUser sharedUser].iconURL,
                                  @"Message": message,
                                  @"Command": @"chat"};
    return [self _generateJSONWithDictionary:messageJSON];
}

- (NSString *)commandWithMessage:(NSString *)message
{
    NSDictionary *messageJSON = [self _extractJSONWithMessage:message];
    if (messageJSON) {
        return messageJSON[@"Command"];
    }
    return nil;
}

- (NSString *)messageJSONWithCommand:(NSString *)command
{
    return [self _generateJSONWithDictionary:@{@"Command": command}];
}

- (NSDictionary *)_extractJSONWithMessage:(NSString *)message
{
    NSError *error = nil;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *messageJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
    if (error) {
        NSLog(@"parse JSON fail : %@", error);
        return nil;
    }
    return messageJSON;
}

- (NSString *)_generateJSONWithDictionary:(NSDictionary *)dictionary
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if (error) {
        NSLog(@"generate JSON fail : %@", error);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
