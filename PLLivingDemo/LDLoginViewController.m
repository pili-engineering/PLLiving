//
//  LDLoginViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLoginViewController.h"

@interface LDLoginViewController ()

@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation LDLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _loginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:LDString("login-by-wechat") forState:UIControlStateNormal];
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
        button;
    });
}

@end
