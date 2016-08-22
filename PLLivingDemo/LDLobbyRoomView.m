//
//  LDLobbyRoomView.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDLobbyRoomView.h"
#import "LDAppearanceView.h"
#import "LDRoomItem.h"
#import "LDURLImageView.h"

@interface LDLobbyRoomView ()
@property (nonatomic, strong) LDURLImageView *previewImageView;
@property (nonatomic, strong) LDURLImageView *anchorImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorNameLabel;
@end

@implementation LDLobbyRoomView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.previewImageView = ({
            LDURLImageView *imageView = [[LDURLImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            
            [self.contentView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.and.bottom.equalTo(self.contentView);
                make.height.mas_equalTo(220);
            }];
            imageView;
        });
        
        ({
            UIView *gradientView = [[LDAppearanceView alloc] initWithLayer:({
                CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                gradientLayer.startPoint = CGPointMake(0, 0);
                gradientLayer.endPoint = CGPointMake(0, 1);
                gradientLayer.locations = @[@0, @0.33, @0.66, @1];
                gradientLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"1A000000"].CGColor,
                                         (__bridge id) [UIColor colorWithHexString:@"005A5A5A"].CGColor,
                                         (__bridge id) [UIColor colorWithHexString:@"00282828"].CGColor,
                                         (__bridge id) [UIColor colorWithHexString:@"AB000000"].CGColor,];
                gradientLayer;
            })];
            [self.contentView addSubview:gradientView];
            [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.and.bottom.equalTo(self.contentView);
            }];
        });
        
        self.anchorImageView = ({
            LDURLImageView *imageView = [[LDURLImageView alloc] init];
            [self.contentView addSubview:imageView];
            imageView.layer.cornerRadius = 10;
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.left.equalTo(self.contentView).with.offset(16);
                make.bottom.equalTo(self.contentView).with.offset(-17);
            }];
            imageView;
        });
        
        self.authorNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [label setTextColor:[UIColor whiteColor]];
            [label setFont:[UIFont systemFontOfSize:12]];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.anchorImageView.mas_right).with.offset(9);
                make.centerY.equalTo(self.anchorImageView);
            }];
            label;
        });
        
        self.titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            [label sizeToFit];
            [label setNumberOfLines:0];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:[UIColor whiteColor]];
            [label setFont:[UIFont systemFontOfSize:18]];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).with.offset(32);
                make.left.equalTo(self.contentView).with.offset(16);
                make.right.equalTo(self.contentView).with.offset(-32);
                make.bottom.lessThanOrEqualTo(self.authorNameLabel).with.offset(-16);
            }];
            label;
        });
    }
    return self;
}

- (void)resetViewWithRoomItem:(LDRoomItem *)roomItem at:(NSUInteger)index
{
    self.anchorImageView.url = [NSURL URLWithString:roomItem.authorIconURL];
    self.previewImageView.url = [NSURL URLWithString:roomItem.previewURL];
    self.titleLabel.text = roomItem.title;
    self.authorNameLabel.text = roomItem.authorName;
}

@end
