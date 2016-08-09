//
//  LDServer.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/8.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDServer : NSObject

+ (instancetype)sharedServer;
- (void)requestMobileCaptchaWithPhoneNumber:(NSString *)phoneNumber withComplete:(void (^)())complete withFail:(void (^)(NSError * _Nullable responseError))failBlock;
- (void)postMobileCaptcha:(NSString *)captcha withPhoneNumber:(NSString *)phoneNumber withComplete:(void (^)(BOOL valid))complete withFail:(void (^)(NSError * _Nullable responseError))failBlock;
- (void)postUserName:(NSString *)username withComplete:(void (^)())complete withFail:(void (^)(NSError * _Nullable responseError))failBlock;
- (void)createNewRoomWithComplete:(void (^)(NSString *pushingURL))complete withFail:(void (^)(NSError * _Nullable responseError))failBlock;

@end
