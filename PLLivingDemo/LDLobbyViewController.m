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
#import "LDServer.h"
#import "LDAnchorRoomViewController.h"
#import "LDSpectatorRoomViewController.h"
#import "LDPanGestureHandler.h"
#import "LDUserSettingViewController.h"

#define kComponentAnimationDuration 0.45
#define kRefreshRoomItemsInterval 10

typedef enum {
    ComponentState_Show,
    ComponentState_Hide
} ComponentState;

@class _LDLobbyTimerKeeper;

@interface LDLobbyViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) _LDLobbyTimerKeeper *timerKeeper;
@property (nonatomic, assign) BOOL isNotEnterAnyRoom;

@property (nonatomic, strong) LDViewConstraintsStateManager *navigationConstraints;
@property (nonatomic, strong) LDViewConstraintsStateManager *startBroadcastingConstraints;
@property (nonatomic, assign) BOOL tableViewTouchTop;
@property (nonatomic, assign) BOOL tableViewTouchBottom;

@property (nonatomic, strong) NSArray<LDRoomItem *> *roomItems;
@property (nonatomic, strong) UIView *emptyBackgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *settingButton;
@property (nonatomic, strong) UIButton *startBroadcastingButton;
@end

@interface _LDLobbyTimerKeeper : NSObject
- (instancetype)initWithLobbyViewController:(LDLobbyViewController *)lobbyViewController;
- (NSTimer *)timer;
@end

@implementation LDLobbyViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.navigationConstraints = [[LDViewConstraintsStateManager alloc] init];
        self.startBroadcastingConstraints = [[LDViewConstraintsStateManager alloc] init];
        self.roomItems = @[];
        self.timerKeeper = [[_LDLobbyTimerKeeper alloc] initWithLobbyViewController:self];
    }
    return self;
}

- (void)dealloc
{
    [self.timerKeeper.timer invalidate];
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
    
    self.emptyBackgroundView = ({
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.hidden = YES;
        
        [self.view addSubview:backgroundView];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-illustration"]];
        [backgroundView addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backgroundView);
            make.size.mas_equalTo(image.image.size);
            make.centerX.equalTo(backgroundView);
        }];
        
        UILabel *mainLabel = [[UILabel alloc] init];
        [mainLabel setText:LDString("no-broadcasting-now")];
        [mainLabel setFont:[UIFont systemFontOfSize:18]];
        [mainLabel setTextColor:[UIColor colorWithHexString:@"99FFFFFF"]];
        
        [backgroundView addSubview:mainLabel];
        [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(image.mas_bottom).with.offset(33);
            make.centerX.equalTo(backgroundView);
        }];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        [descriptionLabel setText:LDString("you-can-begin-to-live")];
        [descriptionLabel setFont:[UIFont systemFontOfSize:12]];
        [descriptionLabel setTextColor:[UIColor colorWithHexString:@"4CFFFFFF"]];
        
        [backgroundView addSubview:descriptionLabel];
        [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(mainLabel.mas_bottom).with.offset(19);
            make.bottom.equalTo(backgroundView);
            make.centerX.equalTo(backgroundView);
        }];
        
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.centerY.equalTo(self.view);
        }];
        backgroundView;
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
    
    [self _setupEventHandler];
    [self _refreshRooms];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.isNotEnterAnyRoom = NO;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.isNotEnterAnyRoom = YES;
//    [self _refreshRooms];
//}

- (void)_fireTimer:(id)sender
{
    if (!self.isNotEnterAnyRoom) {
        [self _refreshRooms];
    }
}

- (void)_refreshRooms
{
    NSLog(@"refresh rooms...");
    [[LDServer sharedServer] getRoomsWithComplete:^(NSArray *jsonArray) {
        
        NSMutableArray<LDRoomItem *> *roomItems = [[NSMutableArray alloc] init];
        for (NSDictionary *roomJson in jsonArray) {
            LDRoomItem *roomItem = [[LDRoomItem alloc] init];
            roomItem.authorID = roomJson[@"AnchorID"];
            roomItem.authorName = roomJson[@"AuthorName"];
            roomItem.authorIconURL = roomJson[@"AuthorIconURL"];
            roomItem.title = roomJson[@"Title"];
            roomItem.previewURL = roomJson[@"PreviewURL"];
            roomItem.rtmpPlayURL = roomJson[@"RTMPPlayURL"];
            roomItem.m3u8PlayURL = roomJson[@"M3U8PlayURL"];
            roomItem.flvPlayURL = roomJson[@"FlvPlayURL"];
            [roomItems addObject:roomItem];
        }
        NSArray<LDRoomItem *> *originalRoomItems = self.roomItems;
        self.roomItems = roomItems;
        self.emptyBackgroundView.hidden = roomItems.count > 0;
        [self _playRefreshRoomsAnimationWithOriginalList:originalRoomItems withTargetList:roomItems];
        
    } withFail:^(NSError * _Nullable responseError) {
        
    }];
}

- (void)_playRefreshRoomsAnimationWithOriginalList:(NSArray<LDRoomItem *> *)originalList
                                    withTargetList:(NSArray<LDRoomItem *> *)targetList
{
    NSMutableArray *originalIDs = [[NSMutableArray alloc] initWithCapacity:originalList.count];
    for (LDRoomItem *roomItem in originalList) {
        [originalIDs addObject:roomItem.authorID];
    }
    NSMutableArray *targetIDs = [[NSMutableArray alloc] initWithCapacity:targetList.count];
    for (LDRoomItem *roomItem in targetList) {
        [targetIDs addObject:roomItem.authorID];
    }
    
    NSMutableArray<NSIndexPath *> *deleteRows = [[NSMutableArray alloc] init];
    NSMutableArray<NSIndexPath *> *insertRows = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < originalIDs.count; i++) {
        NSString *ID = originalIDs[i];
        if (![targetIDs containsObject:ID]) {
            // 已经消失了的房间 authorID。
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [deleteRows addObject:indexPath];
        }
    }
    if (deleteRows.count > 0) {
        [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationRight];
    }
    
    for (NSUInteger i = 0; i < targetIDs.count; i++) {
        NSString *ID = targetIDs[i];
        if (![originalIDs containsObject:ID]) {
            // 新出现的房间 authorID
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [insertRows addObject:indexPath];
        }
    }
    if (insertRows.count > 0) {
        [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)_setupEventHandler
{
    __weak typeof(self) weakSelf = self;
    UIViewAnimationOptions options = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
    
    [LDPanGestureHandler handleView:self.tableView orientation:LDPanGestureHandlerOrientation_Down strengthRate:0.7 recognized:^{
        __strong typeof(self) strongSelf = weakSelf;
        [UIView animateWithDuration:kComponentAnimationDuration delay:0 options:options animations:^{
            strongSelf.navigationConstraints.state = @(ComponentState_Show);
            strongSelf.startBroadcastingConstraints.state = @(ComponentState_Hide);
        } completion:nil];
    }];
    [LDPanGestureHandler handleView:self.tableView orientation:LDPanGestureHandlerOrientation_Up strengthRate:0.7 recognized:^{
        __strong typeof(self) strongSelf = weakSelf;
        
        [UIView animateWithDuration:kComponentAnimationDuration delay:0 options:options animations:^{
            strongSelf.navigationConstraints.state = @(ComponentState_Hide);
            strongSelf.startBroadcastingConstraints.state = @(ComponentState_Show);
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
    LDRoomItem *roomItem = self.roomItems[indexPath.row];
    UIViewController *viewController = [[LDSpectatorRoomViewController alloc] initWithRoomItem:roomItem];
    [self.basicViewController popupViewController:viewController animated:NO completion:nil];
}

@end

@implementation _LDLobbyTimerKeeper
{
    NSTimer *_refreshTimer;
    __weak LDLobbyViewController *_lobbyViewController;
}

- (instancetype)initWithLobbyViewController:(LDLobbyViewController *)lobbyViewController;
{
    if (self = [self init]) {
        _lobbyViewController = lobbyViewController;
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshRoomItemsInterval
                                                         target:self selector:@selector(_fireTimer:)
                                                       userInfo:nil repeats:YES];
    }
    return self;
}

- (void)_fireTimer:(id)sender
{
    [_lobbyViewController _fireTimer:_refreshTimer];
}

- (NSTimer *)timer
{
    return _refreshTimer;
}

@end
