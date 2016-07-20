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
@property (nonatomic, strong) UILabel *chatContentlabel;
@end

@implementation LDChatBubbleView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *bubbleView = ({
            UIView *view = [[UIView alloc] init];
            [self.contentView addSubview:view];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius = 5;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).with.offset(7);
                make.left.equalTo(self.contentView).with.offset(12);
                make.bottom.equalTo(self.contentView).with.offset(-7);
            }];
            view;
        });
        self.chatContentlabel = ({
            UILabel *label = [[UILabel alloc] init];
            [bubbleView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bubbleView).with.offset(7);
                make.left.equalTo(bubbleView).with.offset(4);
                make.bottom.equalTo(bubbleView).with.offset(-7);
                make.right.equalTo(bubbleView).with.offset(-4);
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
