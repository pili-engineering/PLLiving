//
//  LDViewConstraintsStateManager.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/21.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ConstraintMake) (UIView *view, MASConstraintMaker *make);

@interface LDViewConstraintsStateNode : NSObject

- (void)view:(UIView *)view makeConstraints:(ConstraintMake)block;

@end

@interface LDViewConstraintsStateManager : NSObject

@property (nonatomic, strong) id state;
- (void)addState:(id)stateKey makeConstraints:(void (^)(LDViewConstraintsStateNode *node))block;

@end
