//
//  LDLoginViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLoginViewController.h"
#import "LDLobbyViewController.h"
#import "LDAppearanceView.h"

@interface LDLoginViewController ()

@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation LDLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ({
        UIView *backgroundView = [[LDAppearanceView alloc] initWithLayer:({
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(0, 1);
            gradientLayer.locations = @[@0, @0.5, @1];
            gradientLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"E6E6E6"].CGColor,
                                     (__bridge id) [UIColor colorWithHexString:@"F4F4F4"].CGColor,
                                     (__bridge id) [UIColor colorWithHexString:@"FFFFFF"].CGColor,];
            gradientLayer;
        })];
        [self.view addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
    });
    
    ({
        UIImageView *logImageView = [[UIImageView alloc] init];
        logImageView.image = [UIImage imageNamed:@"logo"];
        [self.view addSubview:logImageView];
        [logImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(170);
            make.centerX.equalTo(self.view);
        }];
    });
    
    ({
        UIImageView *titleImageView = [[UIImageView alloc] init];
        titleImageView.image = [UIImage imageNamed:@"LIVING"];
        [self.view addSubview:titleImageView];
        [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(335);
            make.centerX.equalTo(self.view);
        }];
    });
    
    ({
        UILabel *sloganLabel = [[UILabel alloc] init];
        [self.view addSubview:sloganLabel];
        sloganLabel.text = LDString("slogan");
        sloganLabel.textColor = [UIColor colorWithHexString:@"4E4E4E"];
        sloganLabel.font = [UIFont systemFontOfSize:16];
        [sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(398);
            make.centerX.equalTo(self.view);
        }];
    });
    
    self.loginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:button];
        [button setTitle:LDString("login-by-phone-number") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        button.layer.cornerRadius = 25;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [button addTarget:self action:@selector(_onPressedLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(504);
            make.size.mas_equalTo(CGSizeMake(220, 50));
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
