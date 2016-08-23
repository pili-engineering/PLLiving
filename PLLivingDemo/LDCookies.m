//
//  LDCookies.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/8/8.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDCookies.h"
#import "LDUserDefaultsKey.h"

@implementation LDCookies

static LDCookies *_sharedInstance;

+ (void)initialize
{
    _sharedInstance = [[LDCookies alloc] init];
}

+ (instancetype)sharedCookies
{
    return _sharedInstance;
}

- (void)revert
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kLDUserDefaultsKey_StoredCookies]) {
        
        NSMutableArray* cookies = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:kLDUserDefaultsKey_Cookies];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        NSLog(@"REVERT COOKIES {");
        for (NSDictionary* cookieData in cookies) {
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieData];
            [cookieStorage setCookie:cookie];
            NSLog(@"    %@", cookie);
        }
        NSLog(@"}");
    }
}

- (void)store
{
    NSMutableArray* cookieData = [NSMutableArray new];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSLog(@"REVERT COOKIES {");
    for (NSHTTPCookie* cookie in [cookieStorage cookies]) {
        NSMutableDictionary* cookieDictionary = [NSMutableDictionary new];
        cookieDictionary[NSHTTPCookieName] = cookie.name;
        cookieDictionary[NSHTTPCookieValue] = cookie.value;
        cookieDictionary[NSHTTPCookieDomain] = cookie.domain;
        cookieDictionary[NSHTTPCookiePath] = cookie.path;
        cookieDictionary[NSHTTPCookieSecure] = (cookie.isSecure ? @"YES" : @"NO");
        cookieDictionary[NSHTTPCookieVersion] = [NSString stringWithFormat:@"%lu", cookie.version];
        if (cookie.expiresDate) cookieDictionary[NSHTTPCookieExpires] = cookie.expiresDate;
        [cookieData addObject:cookieDictionary];
        NSLog(@"    %@", cookieDictionary);
    }
    NSLog(@"}");
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:kLDUserDefaultsKey_Cookies];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLDUserDefaultsKey_StoredCookies];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)headerFields
{
    return [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
}

@end
