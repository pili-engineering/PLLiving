//
//  LDSpectatorRoomViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/19.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDSpectatorRoomViewController.h"
#import "LDRoomPanelViewController.h"
#import "LDViewConstraintsStateManager.h"
#import "LDAlertUtil.h"
#import "LDRoomItem.h"

typedef enum {
    PanelState_Show,
    PanelState_Hide
} PanelState;

@interface LDSpectatorRoomViewController () <PLPlayerDelegate, LDRoomPanelViewControllerDelegate>
@property (nonatomic, assign) BOOL didPlayFirstFrame;
@property (nonatomic, strong) LDViewConstraintsStateManager *constraints;
@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) LDRoomPanelViewController *roomPanelViewControoler;
@property (nonatomic, strong) UIVisualEffectView *blurBackgroundView;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation LDSpectatorRoomViewController

- (instancetype)initWithRoomItem:(LDRoomItem *)roomItem
{
    if (self = [super init]) {
        self.player = ({
            NSURL *url = [NSURL URLWithString:roomItem.rtmpPlayURL];
            PLPlayer *player = [PLPlayer playerWithURL:url option:[PLPlayerOption defaultOption]];
            player.delegate = self;
            // 允许播放器后台播放。
            player.backgroundPlayEnable = YES;
            // 设置 AVAudioSession 的 Category。
            // 特别注意：禁止在推流过程中修改 AVAudioSession 的 Category。
            // 由于观众房间是不会推流的，所以这里可以安心修改。
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            player;
        });
        self.roomPanelViewControoler = [[LDRoomPanelViewController alloc] initWithMode:LDRoomPanelViewControllerMode_Spectator];
        self.roomPanelViewControoler.delegate = self;
        self.constraints = [[LDViewConstraintsStateManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerContainerView = ({
        UIView *container = [[UIView alloc] init];
        [self.view addSubview:container];
        container.frame = self.view.bounds;
        container.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin;
        container;
    });
    
    ({
        UIView *view = self.player.playerView;
        view.alpha = 0; //在播放器播出第一帧画面前，隐藏它，使观众不至于只能看到一片漆黑。
        view.frame = self.playerContainerView.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight;
        [self.playerContainerView addSubview:view];
    });
    
    self.blurBackgroundView = ({
        UIVisualEffectView *view = [[UIVisualEffectView alloc] init];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
        view;
    });
    
    ({
        UIView *view = self.roomPanelViewControoler.view;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
    });
    
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:button];
        [button setTintColor:[UIColor whiteColor]];
        [button setImage:[UIImage imageNamed:@"icon-big-close"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).with.offset(-22.1);
        }];
        button;
    });
    
    __weak typeof(self) weakSelf = self;
    
    [self.constraints addState:@(PanelState_Hide) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.closeButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 0;
            make.bottom.equalTo(weakSelf.view.mas_top);
        }];
    }];
    [self.constraints addState:@(PanelState_Show) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.closeButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            view.alpha = 1;
            make.top.equalTo(weakSelf.view).with.offset(21.1);
        }];
    }];
    self.constraints.state = @(PanelState_Hide);
    
    [self.closeButton addTarget:self action:@selector(_onPressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.player play];
    [self.roomPanelViewControoler connectToWebSocket];
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.45 animations:^{
        self.blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.65 animations:^{
            self.constraints.state = @(PanelState_Show);
        }];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)onKeyboardWasShownWithHeight:(CGFloat)keyboardHeight withDuration:(NSTimeInterval)duration
{
    CGRect frame = self.view.bounds;
    frame.origin.y = -keyboardHeight/2;
    
    [UIView animateWithDuration:duration animations:^{
        self.playerContainerView.frame = frame;
    }];
}

- (void)onKeyboardWillBeHiddenWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.playerContainerView.frame = self.view.bounds;
    }];
}

- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state
{
    if (state == PLPlayerStatusReady && // 播放器已经完全准备好，可以播放出第一帧了。
        !self.didPlayFirstFrame) {
        [UIView animateWithDuration:0.35 animations:^{
            player.playerView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.55 animations:^{
                self.blurBackgroundView.effect = nil;
            }];
        }];
    }
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error
{
    // 该方法调用的时候，player 已经因为错误的停止了。
    // 如果这个错误能被处理，在处理完这个错误以后，应该调用 [self.player start]，让播放器重新开始播放。
    // 不过这里我没有处理这个错误，仅仅弹出错误信息就退出房间了。
    NSString *title = LDString("player-found-error-and-have-to-exit");
    NSString *message = [NSString stringWithFormat:@"%@", error];
    [LDAlertUtil alertParentViewController:self title:title error:message complete:^{
        [self _closeSpectatorRoomViewController];
    }];
}

- (void)_onPressedCloseButton:(UIButton *)button
{
    // PLPlayer 调用 stop 并非一瞬间可以完成。
    // 这个过程如果放在 Main 线程进行，会阻塞 UI 几百毫秒，这个操作放在另一个线程进行可以让体验好一点。
    PLPlayer *player = self.player;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [player stop];
    });
    [self _closeSpectatorRoomViewController];
}

- (void)_closeSpectatorRoomViewController
{
    [self.roomPanelViewControoler playCloseRoomPanelViewControllerAnimation];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.constraints.state = @(PanelState_Hide);
        self.blurBackgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 animations:^{
            self.blurBackgroundView.effect = nil;
            self.player.playerView.alpha = 0;
            
        } completion:^(BOOL finished) {
            [self.basicViewController removeViewController:self animated:NO completion:nil];
        }];
    }];
}

@end
