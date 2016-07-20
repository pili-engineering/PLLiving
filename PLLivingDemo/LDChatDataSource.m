//
//  LDChatDataSource.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDChatDataSource.h"
#import "LDChatItem.h"
#import "LDChatBubbleView.h"

@interface LDChatDataSource ()
@property (nonatomic, strong) NSMutableArray <LDChatItem *> *chatItems;
@end

@implementation LDChatDataSource

- (instancetype)init
{
    if (self = [super init]) {
        _chatItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatItems.count;
}

- (NSUInteger)count
{
    return self.chatItems.count;
}

- (void)addChatItem:(LDChatItem *)chatItem
{
    [self.chatItems addObject:chatItem];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDChatItem *chatItem = self.chatItems[indexPath.row];
    LDChatBubbleView *cellView = [tableView dequeueReusableCellWithIdentifier:LDChatBubbleViewIdentifer
                                                                forIndexPath:indexPath];
    [cellView resetViewWith:chatItem];
    return cellView;
}

@end
