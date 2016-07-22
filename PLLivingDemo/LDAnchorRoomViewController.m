//
//  LDAnchorRoomViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LDAnchorRoomViewController.h"
#import "LDViewConstraintsStateManager.h"
#import "LDRoomInfoViewController.h"
#import "LDRoomPanelViewController.h"
#import "LDBroadcastingManager.h"
#import "LDDevicePermissionManager.h"
#import "LDAsyncSemaphore.h"
#import "LDAlertUtil.h"

#define kTopBarHeight 70

typedef enum {
    LayoutState_HideTopBar,
    LayoutState_ShowTopBar,
    LayoutState_Float
} LayoutState;

@interface LDAnchorRoomViewController () <LDRoomInfoViewControllerDelegate,
                                          LDRoomPanelViewControllerDelegate,
                                          PLCameraStreamingSessionDelegate>

@property (nonatomic, assign) BOOL didClosed;
@property (nonatomic, assign) BOOL didShowAlertView;
@property (nonatomic, assign) CGFloat previewContainerBeginPosition;
@property (nonatomic, assign) LayoutState originalLayoutStateBeforeGestureBeginning;

@property (nonatomic, strong) PLCameraStreamingSession *cameraStreamingSession;
@property (nonatomic, strong) LDAsyncSemaphore *broadcastingSemaphore;
@property (nonatomic, strong) LDBroadcastingManager *broadcastingManager;
@property (nonatomic, strong) NSString *livingTitle;
@property (nonatomic, strong) LDViewConstraintsStateManager *previewConstraints;

@property (nonatomic, strong) LDRoomInfoViewController *roomInfoViewController;
@property (nonatomic, strong) LDRoomPanelViewController *roomPanelViewControoler;
@property (nonatomic, strong) UIVisualEffectView *blurBackgroundView;
@property (nonatomic, strong) UIImageView *arrowIconView;
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
        self.previewConstraints = [[LDViewConstraintsStateManager alloc] init];
        
        self.roomPanelViewControoler = [[LDRoomPanelViewController alloc] initWithMode:LDRoomPanelViewControllerMode_Anchor];
        self.roomPanelViewControoler.delegate = self;
        
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previewContainer = ({
        UIView *preview = [[UIView alloc] init];
        [self.view addSubview:preview];
        
        __weak typeof(self) weakSelf = self;
        [self.previewConstraints addState:@(LayoutState_HideTopBar) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:preview makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(weakSelf.view);
            }];
        }];
        [self.previewConstraints addState:@(LayoutState_ShowTopBar) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:preview makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.view).with.offset(kTopBarHeight);
                make.height.equalTo(weakSelf.view);
                make.left.and.right.equalTo(weakSelf.view);
            }];
        }];
        [self.previewConstraints addState:@(LayoutState_Float) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:preview makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                make.size.equalTo(weakSelf.view);
                make.left.equalTo(weakSelf.view);
            }];
        }];
        self.previewConstraints.state = @(LayoutState_HideTopBar);
        
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
        self.blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
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
    
    self.topBar = ({
        UIView *bar = [[UIView alloc] init];
        [self.view insertSubview:bar belowSubview:self.previewContainer];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
        bar;
    });
    
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

- (void)viewDidAppear:(BOOL)animated
{
    // 获取摄像头、麦克风权限（如果获取不到，在提示用户之后，直接退回上一级）
    [LDDevicePermissionManager requestDevicePermissionWithParentViewController:self
                                                                  withComplete:^(BOOL success) {
        if (success) {
            // 在拿到摄像头权限之前，preview 是显示不出来的。
            // 因此，直到获取权限成功，才能把 preview 添加到 self.previewContainer 中。
            UIView *preview = self.cameraStreamingSession.previewView;
            self.previewContainer.alpha = 0;
            self.topBar.alpha = 0;
            
            preview.frame = self.previewContainer.bounds;
            preview.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight;
            [self.previewContainer addSubview:preview];
            
            UIViewAnimationOptions options = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
            
            [UIView animateWithDuration:3.5 delay:0 options:options animations:^{
                self.previewContainer.alpha = 1;
            } completion:^(BOOL finished) {
                self.topBar.alpha = 1;
            }];
            
        } else {
            [self.roomInfoViewController closeRoomInfoViewController];
            [self _close];
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
        [self _setupGestureRecognizerForTopBar];
        [self.broadcastingSemaphore signal]; //主播输入完 title，构造好 subivews
    } else {
        [self _close];
    }
}

- (void)_setupAnchorSubviews
{
    ({
        UIView *view = self.roomPanelViewControoler.view;
        [self.previewContainer addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.previewContainer);
        }];
    });
    
    self.arrowIconView = ({
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrows-down"]];
        [self.previewContainer addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.previewContainer).with.offset(20);
            make.right.equalTo(self.previewContainer).with.offset(-18);
        }];
        icon;
    });
    
    self.transferCameraButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topBar addSubview:button];
        [button.layer setCornerRadius:22];
        [button setTintColor:[UIColor blackColor]];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setImage:[UIImage imageNamed:@"toggle-camera"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBar).with.offset(12);
            make.right.equalTo(self.topBar).with.offset(-25);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        button;
    });
    self.stopBroadcastingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.topBar addSubview:button];
        [button setTitle:LDString("stop-broadcasting") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithHexString:@"ED5757"];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.cornerRadius = 22;
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBar).with.offset(12);
            make.left.equalTo(self.topBar).with.offset(22);
            make.size.mas_equalTo(CGSizeMake(260, 44));
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
            self.view.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            self.blurBackgroundView.hidden = YES;
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
    
    self.blurBackgroundView.hidden = NO;
    [self.roomPanelViewControoler playCloseRoomPanelViewControllerAnimation];
    
    [UIView animateWithDuration:0.45 animations:^{
        self.topBar.alpha = 0;
        self.blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.view.backgroundColor = [UIColor clearColor];
        
    } completion:^(BOOL finished) {
        
        CALayer *previewLayer = self.previewContainer.layer.presentationLayer;
        [self.previewContainer.layer removeAllAnimations];
        self.previewContainer.layer.opacity = previewLayer.opacity;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.blurBackgroundView.effect = nil;
            self.previewContainer.alpha = 0;
        } completion:^(BOOL finished) {
            [self.basicViewController removeViewController:self animated:NO completion:nil];
        }];
    }];
}

# pragma mark - move preview to show top bar

- (void)_setupGestureRecognizerForTopBar
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onRecognizeGesture:)];
    [self.previewContainer addGestureRecognizer:gestureRecognizer];
}

- (void)_onRecognizeGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint vector = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.previewContainer.layer removeAllAnimations];
        self.previewContainerBeginPosition = self.previewContainer.frame.origin.y;
        self.originalLayoutStateBeforeGestureBeginning = [self.previewConstraints.state intValue];
        self.previewConstraints.state = @(LayoutState_Float);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.arrowIconView.alpha = 0;
        }];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGSize size = self.view.bounds.size;
        CGFloat touchPosition = self.previewContainerBeginPosition + vector.y;
        CGFloat previewPosition = touchPosition;
        
        if (touchPosition < 0) { // 超过屏幕顶端
            previewPosition = -pow(ABS(touchPosition), 0.75);
        } else if (touchPosition > kTopBarHeight) {
            previewPosition = kTopBarHeight + pow(touchPosition - kTopBarHeight, 0.75);
        }
        gestureRecognizer.view.frame = CGRectMake(0, previewPosition, size.width, size.height);
        
    } else {
        LayoutState finalState;
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {

            if (self.previewContainer.frame.origin.y >= kTopBarHeight/2) {
                finalState = LayoutState_ShowTopBar;
            } else {
                finalState = LayoutState_HideTopBar;
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled || //突然来个电话，恢复原状
                   gestureRecognizer.state == UIGestureRecognizerStateFailed) {
            
            finalState = self.originalLayoutStateBeforeGestureBeginning;
        }
        
        NSTimeInterval duration = 0.35;
        if (finalState == LayoutState_ShowTopBar) {
            duration *= (ABS(vector.y - kTopBarHeight))/kTopBarHeight;
            self.arrowIconView.image = [UIImage imageNamed:@"arrows-up"];
        } else {
            duration *= ABS(vector.y)/kTopBarHeight;
            self.arrowIconView.image = [UIImage imageNamed:@"arrows-down"];
        }
        duration = MIN(duration, 0.35);
        
        UIViewAnimationOptions options = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.previewConstraints.state = @(finalState);
        } completion:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.arrowIconView.alpha = 1;
        }];
    }
    
}

@end
