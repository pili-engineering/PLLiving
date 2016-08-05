//
//  LDRoomPanelViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDRoomPanelViewController.h"
#import "LDLivingConfiguration.h"
#import "LDViewConstraintsStateManager.h"
#import "LDSpectatorListViewController.h"
#import "LDTouchTransparentView.h"
#import "LDChatDataSource.h"
#import "LDChatBubbleView.h"
#import "LDChatItem.h"
#import "LDSpectatorItem.h"
#import "LDTransformTableView.h"
#import "LDAppearanceView.h"
#import "LDPanGestureHandler.h"
#import "LDLivingConfiguration.h"
#import "LDShareViewController.h"

typedef enum {
    LayoutState_Hide,
    LayoutState_Show
} LayoutState;


@interface LDRoomPanelViewController () <UITableViewDelegate, UITextFieldDelegate, SRWebSocketDelegate>

@property (nonatomic, assign) LDRoomPanelViewControllerMode mode;
@property (nonatomic, strong) LDViewConstraintsStateManager *constraints;
@property (nonatomic, assign) CGFloat presetKeyboardHeight;

@property (nonatomic, weak) LDSpectatorListViewController *spectatorListViewController;
@property (nonatomic, weak) LDShareViewController *shareViewController;

@property (nonatomic, strong) SRWebSocket *webSocket;

@property (nonatomic, strong) LDTouchTransparentView *containerView;
@property (nonatomic, strong) LDChatDataSource *chatDataSource;
@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) LDTouchTransparentView *chatTableViewMask;
@property (nonatomic, strong) UITextField *chatTextField;
@property (nonatomic, strong) UIButton *spectatorListButton;
@property (nonatomic, strong) UIButton *sharingButton;
@end

@interface _LDRoomPanelView : LDTouchTransparentView
@property (nonatomic, readonly) LDRoomPanelViewController *roomPanelViewController;
- (instancetype)initWithRomPanelViewController:(LDRoomPanelViewController *)roomPanelViewController;
@end

@implementation LDRoomPanelViewController

- (instancetype)initWithMode:(LDRoomPanelViewControllerMode)mode
{
    if (self = [self init]) {
        _mode = mode;
        _chatDataSource = [[LDChatDataSource alloc] init];
        _constraints = [[LDViewConstraintsStateManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)loadView
{
    self.view = ({
        _LDRoomPanelView *view = [[_LDRoomPanelView alloc] initWithRomPanelViewController:self];
        if (self.mode == LDRoomPanelViewControllerMode_Spectator) {
            // 只有主播才需要 touch 后面的 preview 来调节摄像头 focus。
            // 观众的房间后面是 player，就算遮蔽了也没有关系。
            view.maskAllScreen = YES;
        }
        view;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.containerView = ({
        LDTouchTransparentView *view = [[LDTouchTransparentView alloc] init];
        view.frame = [UIScreen mainScreen].bounds;
        [self.view addSubview:view];
        view.maskAllScreen = NO;
        view;
    });
    
    UIView *bottomBar = ({
        UIView *bar = [[UIView alloc] init];
        [self.containerView addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.equalTo(self.containerView);
            make.height.mas_equalTo(97);
        }];
        UIView *gradientView = [[LDAppearanceView alloc] initWithLayer:({
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(0, 1);
            gradientLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"00000000"].CGColor,
                                     (__bridge id) [UIColor colorWithHexString:@"66000000"].CGColor,];
            gradientLayer;
        })];
        [bar addSubview:gradientView];
        [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.and.bottom.equalTo(bar);
        }];
        UIView *line = [[UIView alloc] init];
        [bar addSubview:line];
        [line setBackgroundColor:[UIColor colorWithHexString:@"56FFFFFF"]];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bar).with.offset(14);
            make.right.equalTo(bar).with.offset(-14);
            make.bottom.equalTo(bar).with.offset(-50);
            make.height.mas_equalTo(1);
        }];
        bar;
    });
    self.spectatorListButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [bottomBar addSubview:button];
        [button setTintColor:[UIColor whiteColor]];
        [button setTitle:@"  321" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setImage:[UIImage imageNamed:@"audience"] forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomBar).with.offset(27);
            make.left.equalTo(bottomBar.mas_left).with.offset(17);
            make.right.lessThanOrEqualTo(bottomBar.mas_left).with.offset(70);
        }];
        button;
    });
    
    if ([[LDLivingConfiguration sharedLivingConfiguration] canUseWechat]) {
        // 只有安装了微信，才显示微信分享的按钮。
        self.sharingButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [bottomBar addSubview:button];
            [button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
            [button setTintColor:[UIColor whiteColor]];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(bottomBar).with.offset(27);
                make.right.equalTo(bottomBar.mas_right).with.offset(-17);
                make.left.greaterThanOrEqualTo(bottomBar.mas_right).with.offset(-51);
            }];
            button;
        });
    } else {
        self.sharingButton = nil;
    }
    
    if (self.mode == LDRoomPanelViewControllerMode_Spectator) {
        // 主播不能打字，她可以直接通过麦克风说话。只有观众需要打字。
        self.chatTextField = ({
            UITextField *field = [[UITextField alloc] init];
            field.enabled = NO; //一开始禁用，当弹幕的 websocket 连接建立后才开启。
            field.delegate = self;
            field.textColor = [UIColor whiteColor];
            field.tintColor = [UIColor whiteColor];
            field.font = [UIFont systemFontOfSize:14];
            field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LDString("chat-placeholder") attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor colorWithHexString:@"99FFFFFF"]}];
            field.backgroundColor = [UIColor colorWithHexString:@"40E5E5E5"];
            field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 10)];
            field.leftViewMode = UITextFieldViewModeAlways;
            field.layer.cornerRadius = 4;
            [field setKeyboardAppearance:UIKeyboardAppearanceAlert];
            [bottomBar addSubview:field];
            [field mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bottomBar).with.offset(54);
                make.bottom.equalTo(bottomBar).with.offset(-5);
                make.left.equalTo(bottomBar).with.offset(70);
                if (self.sharingButton) {
                    make.right.equalTo(self.sharingButton.mas_left).with.offset(-5);
                } else {
                    make.right.equalTo(bottomBar).with.offset(-15);
                }
            }];
            field;
        });
    }
    
    self.chatTableView = ({
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, -1.0);
        LDTransformTableView *tableView = [[LDTransformTableView alloc] initWithTransform:transform];
        [self.containerView addSubview:tableView];
        
        // 如果是主播，UITableView 将可以被“穿透”，当 touch 触碰到它上时，感觉就像穿透它直接 touch 到它后面的 view 一样。
        tableView.canNotMaskGestureRecognizer = (self.mode == LDRoomPanelViewControllerMode_Spectator);
        
        tableView.backgroundColor = [UIColor clearColor];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tableView setShowsVerticalScrollIndicator:NO];
        tableView.estimatedRowHeight = 44.5;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        tableView.dataSource = self.chatDataSource;
        [tableView registerClass:[LDChatBubbleView class] forCellReuseIdentifier:LDChatBubbleViewIdentifer];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView);
            make.width.equalTo(self.containerView);
            make.bottom.equalTo(bottomBar.mas_top).with.offset(44);
        }];
        tableView;
    });
    
    self.chatTableViewMask = ({
        LDTouchTransparentView *mask = [[LDTouchTransparentView alloc] init];
        [self.containerView addSubview:mask];
        [mask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.chatTableView);
        }];
        mask;
    });
    
    __weak typeof(self) weakSelf = self;
    [self.constraints addState:@(LayoutState_Show) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:bottomBar makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            bottomBar.alpha = 1;
            make.bottom.equalTo(weakSelf.containerView);
        }];
        [node view:weakSelf.chatTableView makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.containerView);
        }];
    }];
    [self.constraints addState:@(LayoutState_Hide) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:bottomBar makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            bottomBar.alpha = 1;
            bottomBar.alpha = 0;
            make.top.equalTo(weakSelf.containerView.mas_bottom);
        }];
        [node view:weakSelf.chatTableView makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            bottomBar.alpha = 0;
            make.right.equalTo(weakSelf.containerView.mas_left);
        }];
    }];
    self.constraints.state = @(LayoutState_Hide);
    
    [self.spectatorListButton addTarget:self action:@selector(_onPressedSpectatorListButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sharingButton addTarget:self action:@selector(_onPressedSharingButton:) forControlEvents:UIControlEventTouchUpInside];
    [LDPanGestureHandler handleView:self.chatTableViewMask orientation:LDPanGestureHandlerOrientation_Down
                       strengthRate:1 recognized:^{
        [self.chatTextField resignFirstResponder];
    }];
    
    [self _addNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.65 animations:^{
        self.constraints.state = @(LayoutState_Show);
    }];
}

- (void)playCloseRoomPanelViewControllerAnimation
{
    [self.chatTextField resignFirstResponder];
    [self.webSocket close];
    
    [UIView animateWithDuration:0.65 animations:^{
        self.constraints.state = @(LayoutState_Hide);
    }];
    
    if (self.spectatorListViewController) {
        [self.spectatorListViewController close];
    }
    if (self.shareViewController) {
        [self.shareViewController close];
    }
}

- (void)_addNotifications
{
    NSNotificationCenter *notificationCenger = [NSNotificationCenter defaultCenter];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWasShown:)
                               name:UIKeyboardWillShowNotification object:nil];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWillBeHidden:)
                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)connectToWebSocket
{
    NSString *webSocketURL = [LDLivingConfiguration sharedLivingConfiguration].chatRoomWebsocketURL;
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:webSocketURL]];
    [self.webSocket setDelegate:self];
    [self.webSocket open];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *message = [textField.text stringByReplacingOccurrencesOfRegex:@"(^\\s+|\\s+$)" withString:@""];
    if (![message isEqualToString:@""]) {
        LDChatItem *chatItem = [[LDChatItem alloc] init];
        chatItem.message = message;
        [self.chatDataSource addChatItemToFirst:chatItem];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.chatTableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        [self.chatTextField resignFirstResponder];
    }
    self.chatTextField.text = @"";
    
    return YES;
}

- (void)_onFoundKeyboardWasShown:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.presetKeyboardHeight = keyboardFrame.size.height;
    self.chatTableViewMask.maskAllScreen = YES;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
    if ([self.delegate respondsToSelector:@selector(onKeyboardWasShownWithHeight:withDuration:)]) {
        [self.delegate onKeyboardWasShownWithHeight:self.presetKeyboardHeight withDuration:duration];
    }
}

- (void)_onFoundKeyboardWillBeHidden:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.presetKeyboardHeight = 0;
    self.chatTableViewMask.maskAllScreen = NO;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
    if ([self.delegate respondsToSelector:@selector(onKeyboardWasShownWithHeight:withDuration:)]) {
        [self.delegate onKeyboardWillBeHiddenWithDuration:duration];
    }
}

- (void)_onPressedSpectatorListButton:(UIButton *)button
{
    // 只有观众可以举报主播，主播不能举报自己。
    BOOL enableReportBroadcast = (self.mode == LDRoomPanelViewControllerMode_Spectator);
    
    LDSpectatorListViewController *viewController = [[LDSpectatorListViewController alloc] initWithEnableReportBroadcast:enableReportBroadcast withMoreViewersCount:0 withSpectators:({
        NSMutableArray *array = [[NSMutableArray alloc] init];
        LDSpectatorItem *item;
        
        item = [[LDSpectatorItem alloc] init];
        item.userName = @"moskize";
        [array addObject:item];
        
        item = [[LDSpectatorItem alloc] init];
        item.userName = @"帝王不愧冲天下";
        [array addObject:item];
        
        item = [[LDSpectatorItem alloc] init];
        item.userName = @"大王亲自来巡山";
        [array addObject:item];
        
        array;
    })];
    [self.chatTextField resignFirstResponder];
    [self.basicViewController popupViewController:viewController animated:NO completion:nil];
    [viewController playAppearAnimationWithComplete:nil];
    self.spectatorListViewController = viewController;
}

- (void)_onPressedSharingButton:(UIButton *)button
{
    LDShareViewController *viewController = [[LDShareViewController alloc] initWithPresentOrientation:LDBlurViewControllerPresentOrientation_FromBottom];
    [self.chatTextField resignFirstResponder];
    [self.basicViewController popupViewController:viewController animated:NO completion:nil];
    [viewController playAppearAnimationWithComplete:nil];
    self.shareViewController = viewController;
}

#pragma mark - websocket delete

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"connected to chat room...");
    self.chatTextField.enabled = YES; // 连接建立了，允许用户打字了。
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"websocket found error %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"--> %@", message);
}

@end

@implementation _LDRoomPanelView

- (instancetype)initWithRomPanelViewController:(LDRoomPanelViewController *)roomPanelViewController
{
    if (self = [self init]) {
        _roomPanelViewController = roomPanelViewController;
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect frame = self.bounds;
    frame.origin.y = -_roomPanelViewController.presetKeyboardHeight;
    for (UIView *subview in self.subviews) {
        subview.frame = frame;
    }
    [super layoutSubviews];
}

@end
