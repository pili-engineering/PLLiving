//
//  LDAnchorRoomViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAnchorRoomViewController.h"
#import "LDRoomInfoViewController.h"

@interface LDAnchorRoomViewController () <LDRoomInfoViewControllerDelegate>
@property (nonatomic, strong) LDRoomInfoViewController *rootInfoViewController;
@property (nonatomic, strong) NSString *livingTitle;
@end

@implementation LDAnchorRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rootInfoViewController = ({
        LDRoomInfoViewController *viewController = [[LDRoomInfoViewController alloc] init];
        [self.view addSubview:viewController.view];
        viewController.delegate = self;
        [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
        viewController;
    });
}

- (void)onReciveRoomInfoWithTitle:(NSString *)title
{
    if (title) {
        self.livingTitle = title;
        [self.rootInfoViewController.view removeFromSuperview];
        self.rootInfoViewController = nil;
    } else {
        [self.basicViewController removeViewController:self animated:NO completion:nil];
    }
}

@end
