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

@interface LDLobbyRoomView ()
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *anchorImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorNameLabel;
@end

@implementation LDLobbyRoomView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.previewImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
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
                gradientLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"00FFFFFF"].CGColor,
                                         (__bridge id) [UIColor colorWithHexString:@"AB000000"].CGColor,];
                gradientLayer;
            })];
            [self.contentView addSubview:gradientView];
            [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.and.bottom.equalTo(self.contentView);
            }];
        });
        
        self.anchorImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
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
    NSArray <NSString *> *previewNames = @[@"live1", @"live2"];
    self.previewImageView.image = [UIImage imageNamed:previewNames[index % previewNames.count]];
    self.anchorImageView.image = roomItem.anchorIcon;
    self.titleLabel.text = roomItem.title;
    self.authorNameLabel.text = roomItem.authorName;
}

@end
