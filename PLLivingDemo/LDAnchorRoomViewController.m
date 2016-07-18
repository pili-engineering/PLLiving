//
//  LDAnchorRoomViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAnchorRoomViewController.h"
#import "LDRoomInfoViewController.h"
#import "LDBroadcastingManager.h"
#import "LDDevicePermissionManager.h"

@interface LDAnchorRoomViewController () <LDRoomInfoViewControllerDelegate>
@property (nonatomic, strong) LDRoomInfoViewController *roomInfoViewController;
@property (nonatomic, strong) PLCameraStreamingSession *cameraStreamingSession;
@property (nonatomic, strong) LDBroadcastingManager *broadcastingManager;
@property (nonatomic, strong) NSString *livingTitle;
@end

@implementation LDAnchorRoomViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.broadcastingManager = [[LDBroadcastingManager alloc] init];
        self.cameraStreamingSession = [self.broadcastingManager generateCameraStreamingSession];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.roomInfoViewController = ({
        LDRoomInfoViewController *viewController = [[LDRoomInfoViewController alloc] init];
        [self.view addSubview:viewController.view];
        viewController.delegate = self;
        [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
        viewController;
    });
    
    [LDDevicePermissionManager requestDevicePermissionWithParentViewController:self
                                                                  withComplete:^(BOOL success) {
        if (!success) {
            [self _close];
        }
    }];
    //TODO 获取音频视频采集权
    //TODO 异步获取 PLStream
}

- (void)onReciveRoomInfoWithTitle:(NSString *)title
{
    if (title) {
        self.livingTitle = title;
        [self.roomInfoViewController.view removeFromSuperview];
        self.roomInfoViewController = nil;
    } else {
        [self _close];
    }
}

- (void)_close
{
    [self.basicViewController removeViewController:self animated:NO completion:nil];
}

@end
