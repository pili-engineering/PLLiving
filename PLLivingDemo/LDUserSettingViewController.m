//
//  LDUserSetting.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/26.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDUserSettingViewController.h"
#import "LDSettingNavigationController.h"
#import "LDAppSettingViewController.h"

@interface LDUserSettingViewController()
@property (nonatomic, strong) UIImageView *userIconImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *settingButton;
@end

@implementation LDUserSettingViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *panel = ({
        UIView *panel = [[UIView alloc] init];
        [self.view addSubview:panel];
        panel.backgroundColor = [UIColor whiteColor];
        [panel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.and.left.equalTo(self.view);
            make.width.mas_equalTo(280);
        }];
        panel;
    });
    
    ({
        UIControl *touchCloseControl = [[UIControl alloc] init];
        [self.view addSubview:touchCloseControl];
        [touchCloseControl addTarget:self action:@selector(_onPressedCloseButton:)
                    forControlEvents:UIControlEventTouchUpInside];
        [touchCloseControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.and.bottom.equalTo(self.view);
            make.left.equalTo(panel.mas_right);
        }];
    });
    
    UIView *userIconContainer = ({
        UIView *container = [[UIView alloc] init];
        [panel addSubview:container];
        container.layer.masksToBounds = YES;
        container.layer.cornerRadius = 40;
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(panel).with.offset(78);
            make.centerX.equalTo(panel);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        container;
    });
    
    self.userIconImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [userIconContainer addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"icon2.jpg"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(userIconContainer);
        }];
        imageView;
    });
    
    self.userNameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [panel addSubview:label];
        label.textColor = [UIColor colorWithHexString:@"383838"];
        label.font = [UIFont systemFontOfSize:16];
        label.text = @"Lydia Ray";
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userIconImageView.mas_bottom).with.offset(26);
            make.centerX.equalTo(self.userIconImageView);
        }];
        label;
    });
    
    UIView *topLine = ({
        UIView *line = [[UIView alloc] init];
        [panel addSubview:line];
        line.backgroundColor = [UIColor colorWithHexString:@"E7E7E7"];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(userIconContainer.mas_bottom).with.offset(120);
            make.left.equalTo(panel).with.offset(17);
            make.right.equalTo(panel).with.offset(-3);
            make.height.mas_equalTo(1);
        }];
        line;
    });
    
    UIView *bottomLine = ({
        UIView *line = [[UIView alloc] init];
        [panel addSubview:line];
        line.backgroundColor = [UIColor colorWithHexString:@"E7E7E7"];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topLine).with.offset(56);
            make.left.equalTo(panel).with.offset(17);
            make.right.equalTo(panel).with.offset(-3);
            make.height.mas_equalTo(1);
        }];
        line;
    });
    
    self.settingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [panel addSubview:button];
        [button setTitle:LDString("setting") forState:UIControlStateNormal];
        [button setTintColor:[UIColor colorWithHexString:@"030303"]];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 0);
        [button addTarget:self action:@selector(_onPressedSettingButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topLine.mas_bottom);
            make.bottom.equalTo(bottomLine.mas_top);
            make.left.and.right.equalTo(panel);
        }];
        button;
    });
    
    ({
        UIImageView *arrow = [[UIImageView alloc] init];
        [panel addSubview:arrow];
        arrow.image = [UIImage imageNamed:@"arrows-right"];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(panel).with.offset(-17);
            make.centerY.equalTo(self.settingButton);
        }];
    });
}

- (void)_onPressedSettingButton:(id)sender
{
    LDSettingNavigationController *navigationController = [[LDSettingNavigationController alloc] init];
    [navigationController pushViewController:[[LDAppSettingViewController alloc] init] animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_onPressedCloseButton:(id)sender
{
    [self.basicViewController removeViewController:self animated:NO completion:nil];
    [self playDisappearAnimationWithComplete:nil];
}

@end
