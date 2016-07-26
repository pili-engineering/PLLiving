//
//  LDLobbyViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLobbyViewController.h"
#import "LDViewConstraintsStateManager.h"
#import "LDLobbyRoomView.h"
#import "LDRoomItem.h"
#import "LDAnchorRoomViewController.h"
#import "LDSpectatorRoomViewController.h"
#import "LDPanGestureHandler.h"
#import "LDUserSettingViewController.h"

#define kComponentAnimationDuration 0.45

typedef enum {
    ComponentState_Show,
    ComponentState_Hide
} ComponentState;

@interface LDLobbyViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) LDViewConstraintsStateManager *navigationConstraints;
@property (nonatomic, strong) LDViewConstraintsStateManager *startBroadcastingConstraints;
@property (nonatomic, assign) BOOL tableViewTouchTop;
@property (nonatomic, assign) BOOL tableViewTouchBottom;

@property (nonatomic, strong) NSArray<LDRoomItem *> *roomItems;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *settingButton;
@property (nonatomic, strong) UIButton *startBroadcastingButton;
@end

@implementation LDLobbyViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.navigationConstraints = [[LDViewConstraintsStateManager alloc] init];
        self.startBroadcastingConstraints = [[LDViewConstraintsStateManager alloc] init];
        
        self.roomItems = ({
            NSMutableArray<LDRoomItem *> *array = [[NSMutableArray alloc] init];
            LDRoomItem *roomItem;
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"大家快点来看我直播";
            roomItem.authorName = @"一个人的勇敢";
            roomItem.anchorIcon = [UIImage imageNamed:@"icon1.jpeg"];
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"礼仪培训";
            roomItem.authorName = @"Honney";
            roomItem.anchorIcon = [UIImage imageNamed:@"icon2.jpg"];
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"我以为我会很快乐";
            roomItem.authorName = @"菲";
            roomItem.anchorIcon = [UIImage imageNamed:@"icon3.jpg"];
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"我的直播";
            roomItem.authorName = @"大王亲自来巡山";
            roomItem.anchorIcon = [UIImage imageNamed:@"icon1.jpeg"];
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            array;
        });
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
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] init];
        [self.view addSubview:tableView];
        tableView.backgroundColor = [UIColor blackColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.estimatedRowHeight = 220;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.and.bottom.equalTo(self.view);
        }];
        [tableView registerClass:[LDLobbyRoomView class] forCellReuseIdentifier:LDLobbyRoomViewIdentifer];
        tableView;
    });
    
    self.tableView.tableHeaderView = ({
        UIView *header = [[UIView alloc] init];
        header.frame = CGRectMake(0, 0, 0, 48); //占位
        header;
    });
    
    UINavigationBar *navigationBar = ({
        UINavigationBar *bar = [[UINavigationBar alloc] init];
        [self.view addSubview:bar];
        bar.barStyle = UIBarStyleDefault;
        bar.translucent = NO;
        bar.barTintColor = [UIColor blackColor];
        bar.tintColor = [UIColor whiteColor];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.height.mas_equalTo(48);
        }];
        bar;
    });
    
    [self.navigationConstraints addState:@(ComponentState_Show) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:navigationBar makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view);
        }];
    }];
    [self.navigationConstraints addState:@(ComponentState_Hide) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:navigationBar makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view.mas_top);
        }];
    }];
    self.navigationConstraints.state = @(ComponentState_Show);
    
    UINavigationItem *navigationItem = ({
        UINavigationItem *item = [[UINavigationItem alloc] init];
        [navigationBar pushNavigationItem:item animated:NO];
        item;
    });
    self.settingButton = ({
        UIBarButtonItem *button = [[UIBarButtonItem alloc] init];
        [button setImage:[UIImage imageNamed:@"icon-menu"]];
        navigationItem.leftBarButtonItem = button;
        [button setTarget:self];
        [button setAction:@selector(_onPressedSetting:)];
        button;
    });
    
    self.startBroadcastingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"add-button"] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        [button addTarget:self action:@selector(_onPressedStartBroadcasting:)
         forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        button;
    });
    
    [self.startBroadcastingConstraints addState:@(ComponentState_Show) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.startBroadcastingButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view).with.offset(-36);
        }];
    }];
    [self.startBroadcastingConstraints addState:@(ComponentState_Hide) makeConstraints:^(LDViewConstraintsStateNode *node) {
        [node view:weakSelf.startBroadcastingButton makeConstraints:^(UIView *view, MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view.mas_bottom);
        }];
    }];
    self.startBroadcastingConstraints.state = @(ComponentState_Show);
    
    [self setupEventHandler];
}

- (void)setupEventHandler
{
    __weak typeof(self) weakSelf = self;
    UIViewAnimationOptions options = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
    
    [LDPanGestureHandler handleView:self.tableView orientation:LDPanGestureHandlerOrientation_Down strengthRate:0.7 recognized:^{
        __strong typeof(self) strongSelf = weakSelf;
        [UIView animateWithDuration:kComponentAnimationDuration delay:0 options:options animations:^{
            strongSelf.navigationConstraints.state = @(ComponentState_Hide);
            strongSelf.startBroadcastingConstraints.state = @(ComponentState_Show);
        } completion:nil];
    }];
    [LDPanGestureHandler handleView:self.tableView orientation:LDPanGestureHandlerOrientation_Up strengthRate:0.7 recognized:^{
        __strong typeof(self) strongSelf = weakSelf;
        
        [UIView animateWithDuration:kComponentAnimationDuration delay:0 options:options animations:^{
            strongSelf.navigationConstraints.state = @(ComponentState_Show);
            strongSelf.startBroadcastingConstraints.state = @(ComponentState_Hide);
        } completion:nil];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIViewAnimationOptions options = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
    
    if (self.tableView.contentOffset.y > 0) {
        self.tableViewTouchTop = NO;
        
    } else if (!self.tableViewTouchTop) {
        self.tableViewTouchTop = YES;
        [UIView animateWithDuration:kComponentAnimationDuration delay:0 options:options animations:^{
            self.navigationConstraints.state = @(ComponentState_Show);
        } completion:nil];
    }
    
    if (self.tableView.contentOffset.y < MAX(0, self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
        self.tableViewTouchBottom = NO;
        
    } else if (!self.tableViewTouchTop) {
        self.tableViewTouchBottom = YES;
        [UIView animateWithDuration:kComponentAnimationDuration delay:0 options:options animations:^{
            self.startBroadcastingConstraints.state = @(ComponentState_Show);
        } completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.roomItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDRoomItem *roomItem = self.roomItems[indexPath.row];
    LDLobbyRoomView *cellView = [tableView dequeueReusableCellWithIdentifier:LDLobbyRoomViewIdentifer
                                                                forIndexPath:indexPath];
    [cellView resetViewWithRoomItem:roomItem at:indexPath.row];
    return cellView;
}

- (void)_onPressedStartBroadcasting:(UIButton *)button
{
    [self.basicViewController popupViewController:[[LDAnchorRoomViewController alloc] init]
                                         animated:NO completion:nil];
}

- (void)_onPressedSetting:(UIButton *)button
{
    LDUserSettingViewController *viewController = [[LDUserSettingViewController alloc] initWithPresentOrientation:LDBlurViewControllerPresentOrientation_FromLeft];
    [self.basicViewController popupViewController:viewController animated:NO completion:nil];
    [viewController playAppearAnimationWithComplete:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.basicViewController popupViewController:[[LDSpectatorRoomViewController alloc] initWithURL:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]] animated:NO completion:nil];
}

@end
