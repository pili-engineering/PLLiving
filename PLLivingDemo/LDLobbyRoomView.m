//
//  LDLobbyRoomView.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLobbyRoomView.h"
#import "LDRoomItem.h"

@interface LDLobbyRoomView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorNameLabel;
@property (nonatomic, strong) UILabel *createdTimeLable;
@end

@implementation LDLobbyRoomView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.and.right.equalTo(self.contentView);
                make.height.mas_equalTo(30);
            }];
            label;
        });
        _authorNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_titleLabel.mas_bottom);
                make.left.and.right.equalTo(self.contentView);
                make.height.mas_equalTo(30);
            }];
            label;
        });
        _createdTimeLable = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_authorNameLabel.mas_bottom);
                make.left.and.right.equalTo(self.contentView);
                make.height.mas_equalTo(30);
            }];
            label;
        });
    }
    return self;
}

- (void)resetViewWithRoomItem:(LDRoomItem *)roomItem
{
    _titleLabel.text = roomItem.title;
    _authorNameLabel.text = roomItem.authorName;
    _createdTimeLable.text = [NSString stringWithFormat:@"%@", roomItem.createdTime];
}

@end
