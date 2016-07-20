//
//  LDTransformTableView.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDTransformTableView.h"

@implementation LDTransformTableView

- (instancetype)initWithTransform:(CGAffineTransform)transform
{
    if (self = [self init]) {
        self.transform = transform;
    }
    return self;
}

- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell) {
        cell.transform = CGAffineTransformInvert(self.transform);
    }
    return cell;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView
{
    tableHeaderView.transform = CGAffineTransformInvert(self.transform);
    [super setTableHeaderView:tableHeaderView];
}

- (void)setTableFooterView:(UIView *)tableFooterView
{
    tableFooterView.transform = CGAffineTransformInvert(self.transform);
    [super setTableFooterView:tableFooterView];
}

@end
