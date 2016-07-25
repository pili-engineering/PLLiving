//
//  LDSpectatorListViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDSpectatorListViewController.h"
#import "LDSpectatorItem.h"
#import "LDReportViewController.h"
#import "LDViewConstraintsStateManager.h"

#define kLDSpectatorCellViewIdentifer @"kLDSpectatorCellViewIdentifer"

@interface LDSpectatorListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSUInteger moreViewersCount;
@property (nonatomic, assign) BOOL enableReportBroadcast;
@property (nonatomic, weak) LDReportViewController *reportViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <LDSpectatorItem *> *spectators;
@end

@interface _LDSpectatorCellView : UITableViewCell
@property (nonatomic, strong) LDViewConstraintsStateManager *constraints;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
- (void)resetViewWithSpectatorItem:(LDSpectatorItem *)spectatorItem at:(NSUInteger)index;
@end

@implementation LDSpectatorListViewController

- (instancetype)initWithEnableReportBroadcast:(BOOL)enableReportBroadcast
                         withMoreViewersCount:(NSUInteger)moreViewersCount
                               withSpectators:(NSArray <LDSpectatorItem *> *)spectators
{
    
    if (self = [super initWithPresentOrientation:LDBlurViewControllerPresentOrientation_FromBottom]) {
        self.enableReportBroadcast = enableReportBroadcast;
        self.moreViewersCount = moreViewersCount;
        self.spectators = spectators;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)close
{
    if (self.reportViewController) {
        [self.reportViewController close];
    }
    [self.basicViewController removeViewController:self animated:NO completion:nil];
    [self playDisappearAnimationWithComplete:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ({
        UIView *touchBackgroundView = [[UIView alloc] init];
        [self.view addSubview:touchBackgroundView];
        UIGestureRecognizer *gestureRecognizer;
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(_onPressedBackgroundView:)];
        [touchBackgroundView addGestureRecognizer:gestureRecognizer];
        [touchBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.and.right.equalTo(self.view);
        }];
    });
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] init];
        [self.view addSubview:tableView];
        [tableView setShowsHorizontalScrollIndicator:NO];
        [tableView setShowsVerticalScrollIndicator:NO];
        [tableView setDataSource:self];
        [tableView setDelegate:self];
        [tableView setBackgroundColor:[UIColor clearColor]];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tableView setEstimatedRowHeight:44.5];
        [tableView setRowHeight:UITableViewAutomaticDimension];
        [tableView registerClass:[_LDSpectatorCellView class]
          forCellReuseIdentifier:kLDSpectatorCellViewIdentifer];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self.view);
            make.left.equalTo(self.view).with.offset(28);
            make.right.equalTo(self.view).with.offset(-28);
        }];
        tableView;
    });
    
    self.tableView.tableHeaderView = ({
        UIView *header = [[UIView alloc] init];
        [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onPressedBackgroundView:)]];
        
        UIView *topView = [[UIView alloc] init];
        [header addSubview:topView];
        topView.layer.cornerRadius = 11;
        topView.backgroundColor = [UIColor whiteColor];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(header).with.offset(269);
            make.bottom.left.and.right.equalTo(header);
        }];
        UIView *bottomMaskView = [[UIView alloc] init];
        bottomMaskView.backgroundColor = [UIColor whiteColor];
        [topView addSubview:bottomMaskView];
        [bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(header.mas_bottom).with.offset(-11);
            make.left.right.and.bottom.equalTo(header);
        }];
        
        UILabel *countLabel = [[UILabel alloc] init];
        [topView addSubview:countLabel];
        [countLabel setText:[NSString stringWithFormat:@"%li", self.spectators.count + self.moreViewersCount]];
        [countLabel setFont:[UIFont systemFontOfSize:36]];
        [topView addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topView).with.offset(32);
            make.centerX.equalTo(topView);
        }];
        
        UILabel *viewsLabel = [[UILabel alloc] init];
        [topView addSubview:viewsLabel];
        [viewsLabel setText:LDString("viewers")];
        [viewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(countLabel.mas_bottom).with.offset(11);
            make.bottom.equalTo(topView).with.offset(-30);
            make.centerX.equalTo(topView);
        }];
        
        UIView *splitLine = [[UIView alloc] init];
        [topView addSubview:splitLine];
        [splitLine setBackgroundColor:[UIColor colorWithHexString:@"FFF3F3F3"]];
        [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topView).with.offset(30);
            make.right.equalTo(topView).with.offset(-30);
            make.bottom.equalTo(topView);
            make.height.mas_equalTo(1);
        }];
        [self _resetAutolayoutHeightWithView:header];
        
        header;
    });
    
    self.tableView.tableFooterView = ({
        UIView *footer = [[UIView alloc] init];
        
        UIView *backgroundView = [[UIView alloc] init];
        [footer addSubview:backgroundView];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.and.right.equalTo(footer);
            make.height.mas_equalTo(700);
        }];
        
        UILabel *moreViewersLabel = nil;
        UIView *previousView = nil;
        
        if (self.moreViewersCount > 0) {
            moreViewersLabel = [[UILabel alloc] init];
            [footer addSubview:moreViewersLabel];
            [moreViewersLabel setText:[NSString stringWithFormat:LDString("x-more-viewers"), self.moreViewersCount]];
            [moreViewersLabel setTextColor:[UIColor colorWithHexString:@"FFB3B3B3"]];
            [moreViewersLabel setFont:[UIFont systemFontOfSize:12]];
            [moreViewersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(footer).with.offset(26);
                make.centerX.equalTo(footer);
            }];
            previousView = moreViewersLabel;
        }
        UIView *splitLine = [[UIView alloc] init];
        [footer addSubview:splitLine];
        [splitLine setBackgroundColor:[UIColor colorWithHexString:@"FFF3F3F3"]];
        [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
            if (previousView) {
                make.top.equalTo(previousView.mas_bottom).with.offset(48);
            } else {
                make.top.equalTo(footer);
            }
            make.left.equalTo(footer).with.offset(30);
            make.right.equalTo(footer).with.offset(-30);
            make.height.mas_equalTo(1);
        }];
        previousView = splitLine;
        
        if (self.enableReportBroadcast) {
            UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [footer addSubview:reportButton];
            [reportButton setTitleColor:[UIColor colorWithHexString:@"ED5757"] forState:UIControlStateNormal];
            [reportButton setTitle:LDString("report-broadcast") forState:UIControlStateNormal];
            [reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(previousView.mas_bottom).with.offset(21);
                make.bottom.equalTo(footer).with.offset(-24);
                make.centerX.equalTo(footer);
            }];
            [reportButton addTarget:self action:@selector(_onPressedReportBroadcastButton:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [previousView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(footer).with.offset(-24);
            }];
        }
        [self _resetAutolayoutHeightWithView:footer];
        
        footer;
    });
}

- (void)_onPressedReportBroadcastButton:(id)sender
{
    LDReportViewController *viewController = [[LDReportViewController alloc] initWithPresentOrientation:LDBlurViewControllerPresentOrientation_FromBottom];
    [self.basicViewController popupViewController:viewController animated:NO completion:nil];
    [viewController playAppearAnimationWithComplete:nil];
    self.reportViewController = viewController;
}

- (void)_onPressedBackgroundView:(id)sender
{
    [self close];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL showShareItem = NO;
    if (self.moreViewersCount == 0) {
        showShareItem = YES;
    }
    if (showShareItem) {
        return self.spectators.count + 1;
    } else {
        return self.spectators.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDSpectatorItem *spectatorItem;
    if (indexPath.row < self.spectators.count) {
        spectatorItem = self.spectators[indexPath.row];
    } else {
        spectatorItem = [[LDSpectatorItem alloc] init];
        spectatorItem.userIcon = [UIImage imageNamed:@"Group"];
        spectatorItem.userName = LDString("share");
        spectatorItem.descriptionMessage = LDString("share-get-more-attention");
    }
    _LDSpectatorCellView *cellView = [tableView dequeueReusableCellWithIdentifier:kLDSpectatorCellViewIdentifer
                                                                     forIndexPath:indexPath];
    [cellView resetViewWithSpectatorItem:spectatorItem at:indexPath.row];
    return cellView;
}

- (void)_resetAutolayoutHeightWithView:(UIView *)view
{
    CGRect frame = view.frame;
    UIView *tempContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
    [tempContainer addSubview:view];
    [view setNeedsLayout];
    [view layoutIfNeeded];
    frame.size.height = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [view removeFromSuperview];
    view.frame = frame;
}

@end

typedef enum {
    LayoutState_OnlyName,
    LayoutState_NameAndDescription
} LayoutState;

@implementation _LDSpectatorCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.constraints = [[LDViewConstraintsStateManager alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconImageView = ({
            UIView *iconContainer = [[UIView alloc] init];
            [self.contentView addSubview:iconContainer];
            [iconContainer mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).with.offset(20);
                make.bottom.equalTo(self.contentView).with.offset(-20);
                make.left.equalTo(self.contentView).with.offset(35);
                make.size.mas_equalTo(CGSizeMake(44, 44));
            }];
            iconContainer.layer.masksToBounds = YES;
            iconContainer.layer.cornerRadius = 22;
            
            UIImageView *iconImageView = [[UIImageView alloc] init];
            [iconContainer addSubview:iconImageView];
            [iconContainer addSubview:iconImageView];
            [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.and.bottom.equalTo(iconContainer);
            }];
            iconImageView;
        });
        
        UIView *messageContainer = ({
            UIView *container = [[UIView alloc] init];
            [self.contentView addSubview:container];
            [container mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.iconImageView.mas_right).with.offset(30);
                make.right.equalTo(self.contentView).with.offset(-35);
                make.centerY.equalTo(self.contentView);
            }];
            container;
        });
        
        self.userNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [messageContainer addSubview:label];
            [label setFont:[UIFont systemFontOfSize:16]];
            [label setTextColor:[UIColor colorWithHexString:@"383838"]];
            label;
        });
        
        self.descriptionLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [messageContainer addSubview:label];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextColor:[UIColor colorWithHexString:@"B3B3B3"]];
            label;
        });
        
        __weak typeof(self) weakSelf = self;
        
        [self.constraints addState:@(LayoutState_OnlyName) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:weakSelf.userNameLabel makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(messageContainer);
            }];
            [node view:weakSelf.descriptionLabel makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                weakSelf.descriptionLabel.hidden = YES;
            }];
        }];
        [self.constraints addState:@(LayoutState_NameAndDescription) makeConstraints:^(LDViewConstraintsStateNode *node) {
            [node view:weakSelf.userNameLabel makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                make.top.left.and.right.equalTo(messageContainer);
            }];
            [node view:weakSelf.descriptionLabel makeConstraints:^(UIView *view, MASConstraintMaker *make) {
                weakSelf.descriptionLabel.hidden = NO;
                make.top.equalTo(weakSelf.userNameLabel.mas_bottom).with.offset(1);
                make.left.right.and.bottom.equalTo(messageContainer);
            }];
        }];
    }
    return self;
}

- (void)resetViewWithSpectatorItem:(LDSpectatorItem *)spectatorItem at:(NSUInteger)index
{
    if (!spectatorItem.userIcon) {
        NSArray *array = @[@"icon1.jpeg", @"icon2.jpg", @"icon3.jpg"];
        spectatorItem.userIcon = [UIImage imageNamed:array[index % array.count]];
    }
    [self.iconImageView setImage:spectatorItem.userIcon];
    [self.userNameLabel setText:spectatorItem.userName];
    
    if (spectatorItem.descriptionMessage) {
        [self.descriptionLabel setText:spectatorItem.descriptionMessage];
        self.constraints.state = @(LayoutState_NameAndDescription);
    } else {
        self.constraints.state = @(LayoutState_OnlyName);
    }
}

@end
