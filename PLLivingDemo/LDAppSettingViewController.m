//
//  LDAppSettingViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/27.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAppSettingViewController.h"

@interface LDAppSettingViewController ()
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@end

@implementation LDAppSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    
    [self.navigationItem setTitleView:({
        UILabel *label = [[UILabel alloc] init];
        label.text = LDString("settings");
        label.textColor = [UIColor colorWithHexString:@"030303"];
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        label;
    })];
    
    self.closeButton = ({
        UIBarButtonItem *button = [[UIBarButtonItem alloc] init];
        self.navigationItem.leftBarButtonItem = button;
        [button setImage:[UIImage imageNamed:@"icon-close"]];
        [button setTintColor:[UIColor colorWithHexString:@"B8B8B8"]];
        [button setTarget:self];
        [button setAction:@selector(_pressedCloseButton)];
        button;
    });
    
    UIImageView *appIconView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"logo"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(78);
            make.centerX.equalTo(self.view);
        }];
        imageView;
    });
    
    UIImageView *titleImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"LIVING"];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(appIconView.mas_bottom).with.offset(7);
            make.centerX.equalTo(self.view);
        }];
        imageView;
    });
    
    UILabel *sloganLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [self.view addSubview:label];
        label.text = LDString("slogan");
        label.textColor = [UIColor colorWithHexString:@"4E4E4E"];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleImageView.mas_bottom).with.offset(19);
            make.centerX.equalTo(self.view);
        }];
        label;
    });
    
    UIButton *agreementsButton = ({
        UIButton *button = [self _createSelectItemButtonWithTitle:@"Agreements"];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(sloganLabel.mas_bottom).with.offset(66);
        }];
        button;
    });
    
    UIButton *deleteCacheButton = ({
        UIButton *button = [self _createSelectItemButtonWithTitle:@"Delete Cache"];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(agreementsButton.mas_bottom).with.offset(17);
        }];
        button;
    });
    
    UIButton *logoutButton = ({
        UIButton *button = [self _createSelectItemButtonWithTitle:@"Log Out"];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(deleteCacheButton.mas_bottom).with.offset(17);
        }];
        button;
    });
    
    ({
        UILabel *versionLabel = [[UILabel alloc] init];
        [self.view addSubview:versionLabel];
        versionLabel.text = LDString("version");
        versionLabel.textColor = [UIColor colorWithHexString:@"D8D8D8"];
        versionLabel.font = [UIFont systemFontOfSize:12];
        [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).with.offset(-12);
            make.centerX.equalTo(self.view);
        }];
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIButton *)_createSelectItemButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:[UIColor colorWithHexString:@"030303"] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(56);
    }];
    return button;
}

- (void)_pressedCloseButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
