//
//  LDChatBubbleView.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDChatBubbleView.h"
#import "LDChatItem.h"

@interface LDChatBubbleView ()
@property (nonatomic, strong) UIImageView *userIconView;
@property (nonatomic, strong) UILabel *chatContentlabel;
@end

@implementation LDChatBubbleView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.userIconView = ({
            UIImageView *iconView = [[UIImageView alloc] init];
            [self.contentView addSubview:iconView];
            [iconView.layer setCornerRadius:16];
            [iconView setImage:[UIImage imageNamed:@"icon1.jpeg"]];
            [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(32, 32));
                make.left.equalTo(self.contentView).with.offset(15);
                make.bottom.equalTo(self.contentView).with.offset(-7);
            }];
            iconView;
        });
        
        UIView *bubbleView = ({
            UIView *view = [[UIView alloc] init];
            [self.contentView addSubview:view];
            view.backgroundColor = [UIColor colorWithHexString:@"FFDCDCDC"];
            view.layer.cornerRadius = 16;
            view.alpha = 0.85;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).with.offset(7);
                make.left.equalTo(self.userIconView.mas_right).with.offset(10);
                make.right.lessThanOrEqualTo(self.contentView).with.offset(-25);
                make.bottom.equalTo(self.userIconView);
            }];
            
            UIView *cornerView = [[UIView alloc] init];
            [view addSubview:cornerView];
            cornerView.backgroundColor = [UIColor colorWithHexString:@"FFDCDCDC"];
            cornerView.layer.cornerRadius = 2;
            [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.equalTo(view);
                make.size.mas_equalTo(CGSizeMake(25, 16));
            }];
            view;
        });
        self.chatContentlabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:14];
            [bubbleView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bubbleView).with.offset(13);
                make.left.equalTo(bubbleView).with.offset(20);
                make.bottom.equalTo(bubbleView).with.offset(-16);
                make.right.equalTo(bubbleView).with.offset(-10);
            }];
            label;
        });
    }
    return self;
}

- (void)resetViewWith:(LDChatItem *)chatItem
{
    [self.chatContentlabel setText:chatItem.message];
}

@end
