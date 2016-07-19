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
@property (nonatomic, assign) BOOL didClosed;
@property (nonatomic, strong) LDRoomInfoViewController *roomInfoViewController;
@property (nonatomic, strong) PLCameraStreamingSession *cameraStreamingSession;
@property (nonatomic, strong) LDBroadcastingManager *broadcastingManager;
@property (nonatomic, strong) NSString *livingTitle;
@property (nonatomic, strong) PLStream *streamObject;
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
    
    // 获取摄像头、麦克风权限（如果获取不到，在提示用户之后，直接退回上一级）
    [LDDevicePermissionManager requestDevicePermissionWithParentViewController:self
                                                                  withComplete:^(BOOL success) {
        if (!success) {
            [self _close];
        }
    }];
    
    // 异步获取 PLStream 对象。
    NSURL *streamCloudURL = [NSURL URLWithString:@"http://pili-demo.qiniu.com/api/stream"];
    __weak typeof(self) weakSelf = self;
    
    [self.broadcastingManager generateStreamObject:streamCloudURL withComplete:^(PLStream *streamObject, LDBroadcastingStreamObjectError error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        // 在获取 PLStream 的过程中，self 随时可能被关闭，甚至 dealloc。
        // 在关闭之后，也没有必要对 PLStream 进行处理了。
        if (strongSelf && !strongSelf.didClosed) {
            
            if (error == LDBroadcastingStreamObjectError_NoError) {
                self.streamObject = streamObject;
                [self _onRecivedStreamObject];
                
            } else {
                
            }
        }
    }];
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

- (void)_onRecivedStreamObject
{
    
}

- (void)_close
{
    self.didClosed = YES;
    [self.basicViewController removeViewController:self animated:NO completion:nil];
}

@end
