//
//  LDSettingNavigationController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/27.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDSettingNavigationController.h"
#import "UIImage+Color.h"


@implementation LDSettingNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationBar *bar = self.navigationBar;
    bar.barStyle = UIBarStyleDefault;
    bar.translucent = NO;
    bar.barTintColor = [UIColor whiteColor];
    bar.tintColor = [UIColor blackColor];
    
    [bar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
             forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [bar setShadowImage:[[UIImage alloc] init]];
}

@end
