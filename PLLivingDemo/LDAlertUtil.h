//
//  LDAlertUtil.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDAlertUtil : NSObject

+ (void)alertParentViewController:(UIViewController *)parentViewController
                            title:(NSString *)title error:(NSString *)errorMsg
                         complete:(void (^)())complete;

@end
