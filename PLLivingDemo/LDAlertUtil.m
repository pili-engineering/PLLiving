//
//  LDAlertUtil.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAlertUtil.h"

@implementation LDAlertUtil

+ (void)alertParentViewController:(UIViewController *)parentViewController
                            title:(NSString *)title error:(NSString *)errorMsg
                         complete:(void (^)())complete
{
    UIAlertController *av = [UIAlertController alertControllerWithTitle:title
                                                                message:errorMsg
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [av addAction:[UIAlertAction actionWithTitle:LDString("I-see")
                                           style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             complete();
                                         }]];
    [parentViewController presentViewController:av animated:true completion:nil];
}

@end
