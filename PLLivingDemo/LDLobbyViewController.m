//
//  LDLobbyViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLobbyViewController.h"
#import "LDLobbyRoomView.h"
#import "LDRoomItem.h"
#import "LDAnchorRoomViewController.h"
#import "LDSpectatorRoomViewController.h"

@interface LDLobbyViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray<LDRoomItem *> *roomItems;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *settingButton;
@property (nonatomic, strong) UIButton *startBroadcastingButton;
@end

@implementation LDLobbyViewController

- (instancetype)init
{
    if (self = [super init]) {
        _roomItems = ({
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
    
    UINavigationBar *navigationBar = ({
        UINavigationBar *bar = [[UINavigationBar alloc] init];
        [self.view addSubview:bar];
        bar.barStyle = UIBarStyleDefault;
        bar.translucent = NO;
        bar.barTintColor = [UIColor blackColor];
        bar.tintColor = [UIColor whiteColor];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.height.mas_equalTo(48);
        }];
        bar;
    });
    UINavigationItem *navigationItem = ({
        UINavigationItem *item = [[UINavigationItem alloc] init];
        [navigationBar pushNavigationItem:item animated:NO];
        item;
    });
    self.settingButton = ({
        UIBarButtonItem *button = [[UIBarButtonItem alloc] init];
        [button setImage:[UIImage imageNamed:@"icon-menu"]];
        navigationItem.leftBarButtonItem = button;
        button;
    });
    
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
            make.top.equalTo(navigationBar.mas_bottom);
            make.bottom.equalTo(self.view);
        }];
        [tableView registerClass:[LDLobbyRoomView class] forCellReuseIdentifier:LDLobbyRoomViewIdentifer];
        tableView;
    });
    self.startBroadcastingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"add-button"] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        [button addTarget:self action:@selector(_onPressedStartBroadcasting:)
         forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view).with.offset(-klaystartBroadcastingButtonButtonFloatHeight);
        }];
        button;
    });
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.basicViewController popupViewController:[[LDSpectatorRoomViewController alloc] initWithURL:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]] animated:NO completion:nil];
}

@end
