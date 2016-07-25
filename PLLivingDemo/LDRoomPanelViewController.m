//
//  LDRoomPanelViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDRoomPanelViewController.h"
#import "LDViewConstraintsStateManager.h"
#import "LDSpectatorListViewController.h"
#import "LDTouchTransparentView.h"
#import "LDChatDataSource.h"
#import "LDChatBubbleView.h"
#import "LDChatItem.h"
#import "LDSpectatorItem.h"
#import "LDTransformTableView.h"
#import "LDAppearanceView.h"

typedef enum {
    LayoutState_Hide,
    LayoutState_Show
} LayoutState;


@interface LDRoomPanelViewController () <UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) LDRoomPanelViewControllerMode mode;
@property (nonatomic, strong) LDViewConstraintsStateManager *constraints;
@property (nonatomic, assign) CGFloat presetKeyboardHeight;

@property (nonatomic, weak) LDSpectatorListViewController *spectatorListViewController;

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
    
    if (self.mode == LDRoomPanelViewControllerMode_Spectator) {
        // 主播不能打字，她可以直接通过麦克风说话。只有观众需要打字。
        self.chatTextField = ({
            UITextField *field = [[UITextField alloc] init];
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
                make.right.equalTo(bottomBar).with.offset(-51);
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
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onRecognizeGesture:)];
        [mask addGestureRecognizer:gestureRecognizer];
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
    
    [self addNotifications];
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
    
    [UIView animateWithDuration:0.65 animations:^{
        self.constraints.state = @(LayoutState_Hide);
    }];
    
    if (self.spectatorListViewController) {
        [self.spectatorListViewController close];
    }
}

- (void)addNotifications
{
    NSNotificationCenter *notificationCenger = [NSNotificationCenter defaultCenter];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWasShown:)
                               name:UIKeyboardWillShowNotification object:nil];
    [notificationCenger addObserver:self selector:@selector(_onFoundKeyboardWillBeHidden:)
                               name:UIKeyboardWillHideNotification object:nil];
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

- (void)_onRecognizeGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    // 判定是否是一个手指下滑的手势。
    CGPoint displacement = [gestureRecognizer translationInView:self.chatTableViewMask]; // 位移矢量
    CGPoint velocity = [gestureRecognizer velocityInView:self.chatTableViewMask]; //速度矢量
    CGFloat radian = atan2(displacement.y, displacement.x); // 位移的弧度
    CGFloat radius2 = pow(displacement.x, 2) + pow(displacement.y, 2); // 位移的半径平方
    CGFloat speed2 = pow(velocity.x, 2) + pow(velocity.y, 2); // 速率的平方
    
    if (radius2 >= pow(128, 2) && speed2 >= pow(600, 2) && (M_PI_4 <= radian && 3*M_PI_4)) {
        [self.chatTextField resignFirstResponder];
    }
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
    
    LDSpectatorListViewController *viewController = [[LDSpectatorListViewController alloc] initWithEnableReportBroadcast:enableReportBroadcast withMoreViewersCount:12 withSpectators:({
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
