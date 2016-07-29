//
//  LDLoginViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLoginViewController.h"
#import "LDLoginFlowViewController.h"
#import "LDLobbyViewController.h"
#import "LDAppearanceView.h"
#import "UIImage+Color.h"

@interface LDLoginViewController () <LDLoginFlowViewControllerDelegate>

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
    
    UIView *viewContainer = ({
        UIView *container = [[UIView alloc] init];
        [self.view addSubview:container];
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.centerY.equalTo(self.view);
        }];
        container;
    });
    
    ({
        UIImageView *logImageView = [[UIImageView alloc] init];
        logImageView.image = [UIImage imageNamed:@"logo"];
        [viewContainer addSubview:logImageView];
        [logImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewContainer).with.offset(20);
            make.centerX.equalTo(viewContainer);
        }];
    });
    
    ({
        UIImageView *titleImageView = [[UIImageView alloc] init];
        titleImageView.image = [UIImage imageNamed:@"LIVING"];
        [viewContainer addSubview:titleImageView];
        [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewContainer).with.offset(185);
            make.centerX.equalTo(viewContainer);
        }];
    });
    
    ({
        UILabel *sloganLabel = [[UILabel alloc] init];
        [viewContainer addSubview:sloganLabel];
        sloganLabel.text = LDString("slogan");
        sloganLabel.textColor = [UIColor colorWithHexString:@"4E4E4E"];
        sloganLabel.font = [UIFont systemFontOfSize:16];
        [sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewContainer).with.offset(248);
            make.centerX.equalTo(viewContainer);
        }];
    });
    
    self.loginButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [viewContainer addSubview:button];
        [button setTitle:LDString("login-by-phone-number") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        button.layer.cornerRadius = 25;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [button addTarget:self action:@selector(_onPressedLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(viewContainer);
            make.top.equalTo(viewContainer).with.offset(354);
            make.bottom.equalTo(viewContainer);
            make.size.mas_equalTo(CGSizeMake(220, 50));
        }];
        button;
    });
}

- (void)_onPressedLoginButton:(UIButton *)button
{
    
    UINavigationController *navigationController = ({
        UINavigationController *nc = [[UINavigationController alloc] init];
        UINavigationBar *bar = nc.navigationBar;
        bar.barStyle = UIBarStyleDefault;
        bar.translucent = NO;
        bar.barTintColor = [UIColor whiteColor];
        bar.tintColor = [UIColor blackColor];
        
        [bar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
                 forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [bar setShadowImage:[[UIImage alloc] init]];
        nc;
    });
    LDLoginFlowViewController *flowViewController = [LDLoginFlowViewController loginFlowViewController];
    flowViewController.delegate = self;
    [navigationController pushViewController:flowViewController animated:NO];
    [self.view.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)flowViewControllerComplete:(LDLoginFlowViewController *)flowViewController
{
    LDLobbyViewController *lobbyViewController = [[LDLobbyViewController alloc] init];
    [self.basicViewController popupViewController:lobbyViewController animated:NO completion:^{
        [self.basicViewController removeViewController:self animated:NO completion:nil];
        [flowViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
