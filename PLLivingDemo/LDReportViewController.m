//
//  LDReportViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/25.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDReportViewController.h"

@interface LDReportViewController ()
@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation LDReportViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *container = ({
        UIView *view = [[UIView alloc] init];
        [self.view addSubview:view];
        view.backgroundColor = [UIColor colorWithHexString:@"010101"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(153);
        }];
        view;
    });
    UILabel *descriptionLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [container addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.text = LDString("sure-to-report-this-broadcast");
        label.textColor = [UIColor colorWithHexString:@"848484"];
        label.textAlignment = NSTextAlignmentCenter;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(container).with.offset(19);
            make.left.and.right.equalTo(container);
        }];
        label;
    });
    self.reportButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [container addSubview:button];
        [button.layer setCornerRadius:22];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:LDString("report-content") forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithHexString:@"ED5757"]];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(descriptionLabel.mas_bottom).with.offset(18);
            make.centerX.equalTo(container);
            make.size.mas_equalTo(CGSizeMake(260, 44));
        }];
        [button addTarget:self action:@selector(_pressedReportButton:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    self.cancelButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [container addSubview:button];
        [button setTitleColor:[UIColor colorWithHexString:@"B8B8B8"] forState:UIControlStateNormal];
        [button setTitle:LDString("cancel") forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.reportButton.mas_bottom).with.offset(5);
            make.centerX.equalTo(container);
            make.bottom.equalTo(container);
        }];
        [button addTarget:self action:@selector(_pressedCancelButton:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
}

- (void)_pressedReportButton:(id)sender
{
    
}

- (void)_pressedCancelButton:(id)sender
{
    [self close];
}

- (void)close
{
    [self.basicViewController removeViewController:self animated:NO completion:nil];
    [self playDisappearAnimationWithComplete:nil];
}

@end
