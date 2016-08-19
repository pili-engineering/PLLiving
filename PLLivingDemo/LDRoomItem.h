//
//  PLRoomItem.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDRoomItem : NSObject

@property (nonatomic, strong) NSString *authorID;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *authorIconURL;
@property (nonatomic, strong) NSString *previewURL;
@property (nonatomic, strong) NSString *playURL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *createdTime;

@end
