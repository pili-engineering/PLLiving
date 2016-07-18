//
//  LDDevicePermissionManager.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDDevicePermissionManager : NSObject

+ (void)requestDevicePermissionWithParentViewController:(UIViewController *)parentViewController
                                           withComplete:(void (^)(BOOL success))completeBlock;

@end
