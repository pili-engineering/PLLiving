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

@interface LDLobbyViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray<LDRoomItem *> *roomItems;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UINavigationBar *navigationBar;
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
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"礼仪培训";
            roomItem.authorName = @"Honney";
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"我以为我会很快乐";
            roomItem.authorName = @"菲";
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            roomItem = [[LDRoomItem alloc] init];
            roomItem.title = @"我的直播";
            roomItem.authorName = @"大王亲自来巡山";
            roomItem.createdTime = [[NSDate alloc] init];
            [array addObject:roomItem];
            
            array;
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _navigationBar = ({
        UINavigationBar *bar = [[UINavigationBar alloc] init];
        [self.view addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(klayStatusBarHeight);
            make.height.mas_equalTo(kNavigationBarHeight);
        }];
        bar;
    });
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] init];
        [self.view addSubview:tableView];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(_navigationBar.mas_bottom);
            make.bottom.equalTo(self.view);
        }];
        [tableView registerClass:[LDLobbyRoomView class] forCellReuseIdentifier:LDLobbyRoomViewIdentifer];
        tableView;
    });
    _startBroadcastingButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:button];
        [button setTitle:@"开始直播(+)" forState:UIControlStateNormal];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return klayLobbyRoomTabHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDRoomItem *roomItem = self.roomItems[indexPath.row];
    LDLobbyRoomView *cellView = [tableView dequeueReusableCellWithIdentifier:LDLobbyRoomViewIdentifer
                                                                forIndexPath:indexPath];
    [cellView resetViewWithRoomItem:roomItem];
    return cellView;
}

- (void)_onPressedStartBroadcasting:(UIButton *)button
{
    
}

@end
