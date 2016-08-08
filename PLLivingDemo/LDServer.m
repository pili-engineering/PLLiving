//
//  LDServer.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/8.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDServer.h"
#import "LDLivingConfiguration.h"

@implementation LDServer

static LDServer *_sharedInstance;

+ (void)initialize
{
    _sharedInstance = [[LDServer alloc] init];
}

+ (instancetype)sharedServer
{
    return _sharedInstance;
}

- (void)requestMobileCaptchaWithPhoneNumber:(NSString *)phoneNumber withComplete:(void (^)())complete withFail:(void (^)(NSError * _Nullable responseError))failBlock
{
    [self _url:[self _httpURLWithPath:@"/mobile"] request:^(NSMutableURLRequest *request) {
        
        request.HTTPMethod = @"POST";
        request.HTTPBody = [self _httpBodyWithParams:@{@"mobile": phoneNumber}];
        
    } success:^(NSData * _Nullable data, NSURLResponse * _Nullable response) {
        
        complete();
        
    } fail:failBlock];
}

- (NSURL *)_httpURLWithPath:(NSString *)path
{
    NSString *serverURL = [LDLivingConfiguration sharedLivingConfiguration].httpServerURL;
    serverURL = [serverURL stringByReplacingOccurrencesOfRegex:@"/$" withString:@""];
    path = [path stringByReplacingOccurrencesOfRegex:@"^/" withString:@""];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", serverURL, path]];
}

- (NSData *)_httpBodyWithParams:(NSDictionary *)params
{
    NSMutableArray *entiyArray = [[NSMutableArray alloc] init];
    for (NSString *key in params) {
        NSString *value = params[key];
        [entiyArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    NSString *body = [entiyArray componentsJoinedByString:@"&"];
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)_url:(NSURL *)url
     request:(void (^)(NSMutableURLRequest *request))requestSettingBlock
     success:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response))successBlock
        fail:(void (^)(NSError * _Nullable responseError))failBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:10];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if (requestSettingBlock) {
        requestSettingBlock(request);
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable responseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = responseError;
            if (error != nil || response == nil || data == nil) {
                NSLog(@"ERROR: %@", error);
                if (failBlock) {
                    failBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock(data, response);
                }
            }
        });
    }];
    [task resume];
}

@end
