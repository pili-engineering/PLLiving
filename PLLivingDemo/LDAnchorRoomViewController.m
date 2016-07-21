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
#import "LDAsyncSemaphore.h"
#import "LDAlertUtil.h"

@interface LDAnchorRoomViewController () <LDRoomInfoViewControllerDelegate,
                                          PLCameraStreamingSessionDelegate>

@property (nonatomic, assign) BOOL didClosed;
@property (nonatomic, assign) BOOL didShowAlertView;

@property (nonatomic, strong) PLCameraStreamingSession *cameraStreamingSession;
@property (nonatomic, strong) LDAsyncSemaphore *broadcastingSemaphore;
@property (nonatomic, strong) LDBroadcastingManager *broadcastingManager;
@property (nonatomic, strong) NSString *livingTitle;

@property (nonatomic, strong) LDRoomInfoViewController *roomInfoViewController;
@property (nonatomic, strong) UIVisualEffectView *blurBackgroundView;
@property (nonatomic, strong) UIView *previewContainer;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *transferCameraButton;
@property (nonatomic, strong) UIButton *stopBroadcastingButton;

@end

@implementation LDAnchorRoomViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.broadcastingManager = [[LDBroadcastingManager alloc] init];
        
        // 需要等待 3 个信号后才能开始推流（信号都是异步的，先后完全不可预测）
        // 1. 主播输入完 title，构造好 subivews。
        // 2. 等待服务器返回 PLStream 对象。
        // 3. 等待服务器返回房间信息。
        NSInteger semaphoreValue = 2;
        self.broadcastingSemaphore = [[LDAsyncSemaphore alloc] initWithValue:semaphoreValue];
        [self.broadcastingSemaphore waitWithTarget:self withAction:@selector(_beginBroadcasting)];
        
        self.cameraStreamingSession = [self.broadcastingManager generateCameraStreamingSession];
        self.cameraStreamingSession.delegate = self;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previewContainer = ({
        UIView *preview = [[UIView alloc] init];
        [self.view addSubview:preview];
        [preview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
        preview;
    });
    
    self.blurBackgroundView = ({
        UIVisualEffectView *view = [[UIVisualEffectView alloc] init];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
        view;
    });
    
    [UIView animateWithDuration:0.35 animations:^{
        self.blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    } completion:^(BOOL finished) {
        
        self.roomInfoViewController = ({
            LDRoomInfoViewController *viewController = [[LDRoomInfoViewController alloc] init];
            viewController.delegate = self;
            [self.view addSubview:viewController.view];
            [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(self.view);
            }];
            viewController;
        });
    }];
    
    // 获取摄像头、麦克风权限（如果获取不到，在提示用户之后，直接退回上一级）
    [LDDevicePermissionManager requestDevicePermissionWithParentViewController:self
                                                                  withComplete:^(BOOL success) {
        if (success) {
            // 在拿到摄像头权限之前，preview 是显示不出来的。
            // 因此，直到获取权限成功，才能把 preview 添加到 self.previewContainer 中。
            UIView *preview = self.cameraStreamingSession.previewView;
            
            self.previewContainer.alpha = 0;
            [self.previewContainer addSubview:preview];
            [preview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(self.previewContainer);
            }];
            
            [UIView animateWithDuration:3.5 animations:^{
                self.previewContainer.alpha = 1;
            }];
            
        } else {
            [self _close];
        }
    }];
    
    // 异步获取 PLStream 对象。
    // 我之所以要异步获取，是为了让主播在输入 title 的同时，也在等待服务器返回 PLStream 对象。
    // 很可能主播输入完 title 之前，PLStream 就已经拿到了。
    // 这样会减少主播等待的时间，体验会好一点。
    NSURL *streamCloudURL = [NSURL URLWithString:@"http://pili-demo.qiniu.com/api/stream"];
    __weak typeof(self) weakSelf = self;
    
    [self.broadcastingManager generateStreamObject:streamCloudURL withComplete:^(PLStream *streamObject, LDBroadcastingStreamObjectError error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        // 在获取 PLStream 的过程中，self 随时可能被关闭，甚至 dealloc。
        // 因为主播随时可以叉掉，然后返回上一级界面。
        // 在关闭之后，也没有必要对 PLStream 进行处理了。
        if (strongSelf && !strongSelf.didClosed) {
            
            if (error == LDBroadcastingStreamObjectError_NoError) {
                strongSelf.cameraStreamingSession.stream = streamObject;
                [strongSelf.broadcastingSemaphore signal]; //接收到了 PLStream 对象。
            } else {
                // TODO
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
        [self _setupAnchorSubviews];
        [self.broadcastingSemaphore signal]; //主播输入完 title，构造好 subivews
    } else {
        [self _close];
    }
}

- (void)_setupAnchorSubviews
{
    self.topBar = ({
        UIView *bar = [[UIView alloc] init];
        bar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.and.right.equalTo(self.view);
            make.height.mas_equalTo(klayStatusBarHeight + klayBroadcastingTopBarHeight);
        }];
        bar;
    });
    self.transferCameraButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.topBar addSubview:button];
        [button setTitle:@"转" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.bottom.equalTo(self.topBar).with.offset(-7);
        }];
        button;
    });
    self.stopBroadcastingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.topBar addSubview:button];
        [button setTitle:LDString("stop-broadcasting") forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topBar).with.offset(7);
            make.bottom.equalTo(self.topBar).with.offset(-7);
            make.right.equalTo(self.transferCameraButton.mas_left).with.offset(-7);
        }];
        button;
    });
    
    [self.transferCameraButton addTarget:self action:@selector(_onPressedTransferCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopBroadcastingButton addTarget:self action:@selector(_onPressedStopBroadcastingButton:) forControlEvents:UIControlEventTouchUpInside];
}

// 当允许推流开始的 3 个必要条件（对应 3 个信号）全部满足时，这个方法被回调。
- (void)_beginBroadcasting
{
    if (!self.didClosed) {
        [self.cameraStreamingSession startWithCompleted:^(BOOL success) {
            // 这个回调方法不在 Main 线程中，如果涉及 UI 操作需转到 Main 线程中处理。
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self.view makeToast:LDString("connected-and-is-broadcasting")
                                duration:1.2 position:CSToastPositionCenter];
                } else {
                    [self _closeAndAlertErrorMessage:LDString("can-not-connect-to-server-when-begin-broadcasting")];
                }
            });
        }];
        [UIView animateWithDuration:0.45 animations:^{
            self.blurBackgroundView.effect = nil;
        }];
    }
}

- (void)_onPressedTransferCameraButton:(UIButton *)button
{
    [self.cameraStreamingSession toggleCamera];
}

- (void)_onPressedStopBroadcastingButton:(UIButton *)button
{
    if (!self.didClosed) {
        if (self.cameraStreamingSession.isRunning) {
            [self.cameraStreamingSession stop];
        }
        [self _close];
    }
}

// 推流时发生错误，导致推流终止时，会调用这个方法。该方法来自 PLCameraStreamingSessionDelegate。
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session didDisconnectWithError:(NSError *)error
{
    if (!self.didClosed) {
        [self _closeAndAlertErrorMessage:LDString("broadcast-disconnected-because-found-error")];
    }
}

- (void)_closeAndAlertErrorMessage:(NSString *)errorMessage
{
    if (!self.didShowAlertView) {
        self.didShowAlertView = YES;
        [LDAlertUtil alertParentViewController:self title:errorMessage error:LDString("found-error-while-broadcasting-and-have-to-close") complete:^{
            [self _close];
            self.didShowAlertView = NO;
        }];
    }
}

- (void)_close
{
    self.didClosed = YES;
    
    [self.previewContainer.layer removeAllAnimations];
    [UIView animateWithDuration:0.5 animations:^{
        self.previewContainer.alpha = 0;
        self.blurBackgroundView.effect = nil;
    } completion:^(BOOL finished) {
        [self.basicViewController removeViewController:self animated:NO completion:nil];
    }];
}

@end
