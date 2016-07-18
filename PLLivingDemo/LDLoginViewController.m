//
//  LDLoginViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLoginViewController.h"
#import "LDLobbyViewController.h"

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
        [button addTarget:self action:@selector(_onPressedLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
        button;
    });
}

- (void)_onPressedLoginButton:(UIButton *)button
{
    LDLobbyViewController *lobbyViewController = [[LDLobbyViewController alloc] init];
    [self.basicViewController popupViewController:lobbyViewController animated:YES completion:^{
        [self.basicViewController removeViewController:self animated:NO completion:nil];
    }];
}

@end
