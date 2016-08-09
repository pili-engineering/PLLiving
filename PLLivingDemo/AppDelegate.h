//
//  AppDelegate.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#define kLDUserDefaultsKey_DidLogin @"DidLogin"
#define kLDUserDefaultsKey_Cookies @"Cookies"
#define kLDUserDefaultsKey_StoredCookies @"StoredCookies"

@property (strong, nonatomic) UIWindow *window;


@end

