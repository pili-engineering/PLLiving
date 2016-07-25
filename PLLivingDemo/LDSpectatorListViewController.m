//
//  LDSpectatorListViewController.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDSpectatorListViewController.h"
#import "LDSpectatorItem.h"

#define kLDSpectatorCellViewIdentifer @"kLDSpectatorCellViewIdentifer"

@interface LDSpectatorListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSUInteger moreViewersCount;
@property (nonatomic, assign) BOOL enableReportBroadcast;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <LDSpectatorItem *> *spectators;
@end

@interface _LDSpectatorCellView : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
- (void)resetViewWithSpectatorItem:(LDSpectatorItem *)spectatorItem at:(NSUInteger)index;
@end

@implementation LDSpectatorListViewController

- (instancetype)initWithSpectators:(NSArray <LDSpectatorItem *> *)spectators
{
    if (self = [super initWithPresentOrientation:LDBlurViewControllerPresentOrientation_FromBottom]) {
        self.spectators = spectators;
        self.enableReportBroadcast = YES;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)close
{
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
        [countLabel setText:[NSString stringWithFormat:@"%li", self.spectators.count]];
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
        }
        UIView *splitLine = [[UIView alloc] init];
        [footer addSubview:splitLine];
        [splitLine setBackgroundColor:[UIColor colorWithHexString:@"FFF3F3F3"]];
        [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
            if (moreViewersLabel) {
                make.top.equalTo(moreViewersLabel.mas_bottom).with.offset(48);
            } else {
                make.top.equalTo(footer);
            }
            make.left.equalTo(footer).with.offset(30);
            make.right.equalTo(footer).with.offset(-30);
            make.height.mas_equalTo(1);
        }];
        
        if (self.enableReportBroadcast) {
            UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [footer addSubview:reportButton];
            [reportButton setTitleColor:[UIColor colorWithHexString:@"ED5757"] forState:UIControlStateNormal];
            [reportButton setTitle:LDString("report-broadcast") forState:UIControlStateNormal];
            [reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(splitLine).with.offset(21);
                make.bottom.equalTo(footer).with.offset(-24);
                make.centerX.equalTo(footer);
            }];
        }
        [self _resetAutolayoutHeightWithView:footer];
        
        footer;
    });
}

- (void)_onPressedBackgroundView:(id)sender
{
    [self close];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.spectators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDSpectatorItem *spectatorItem = self.spectators[indexPath.row];
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

@implementation _LDSpectatorCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
        
        self.userNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            [label setFont:[UIFont systemFontOfSize:16]];
            [label setTextColor:[UIColor colorWithHexString:@"383838"]];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.iconImageView.mas_right).with.offset(30);
                make.right.equalTo(self.contentView).with.offset(-35);
                make.centerY.equalTo(self.contentView);
            }];
            label;
        });
    }
    return self;
}

- (void)resetViewWithSpectatorItem:(LDSpectatorItem *)spectatorItem at:(NSUInteger)index
{
    NSArray *array = @[@"icon1.jpeg", @"icon2.jpg", @"icon3.jpg"];
    [self.iconImageView setImage:[UIImage imageNamed:array[index % array.count]]];
    [self.userNameLabel setText:spectatorItem.userName];
}

@end
