//
//  LDViewConstraintsStateManager.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/21.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDViewConstraintsStateManager.h"

@interface LDViewConstraintsStateManager ()

@property (nonatomic, strong) NSMutableDictionary <id, LDViewConstraintsStateNode *> *nodeDictionary;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> * previousConstaints;
@end

@interface LDViewConstraintsStateNode ()

@property (nonatomic, strong) id stateKey;
@property (nonatomic, strong) NSMutableArray <UIView *> *views;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, ConstraintMake> *constraitnsDictionary;

- (instancetype)initWithStateKey:(id)stateKey;
- (NSMutableArray<MASConstraint *> *)install;

@end

@implementation LDViewConstraintsStateManager

- (instancetype)init
{
    if (self = [super init]) {
        _nodeDictionary = [[NSMutableDictionary <id, LDViewConstraintsStateNode *> alloc] init];
    }
    return self;
}

- (void)addState:(id)stateKey makeConstraints:(void (^)(LDViewConstraintsStateNode *node))block
{
    if (!self.nodeDictionary[stateKey]) {
        LDViewConstraintsStateNode *node = [[LDViewConstraintsStateNode alloc] initWithStateKey:stateKey];
        block(node);
        self.nodeDictionary[stateKey] = node;
    }
}

- (void)setState:(id)state
{
    _state = state;
    
    if (self.previousConstaints) {
        for (MASConstraint *constraint in self.previousConstaints) {
            [constraint uninstall];
        }
    }
    LDViewConstraintsStateNode *node = self.nodeDictionary[state];
    self.previousConstaints = [node install];
    
    NSMutableSet<UIView *>*viewSuperviews = ({
        NSMutableSet<UIView *> *set = [[NSMutableSet<UIView *> alloc] init];
        for (UIView *view in node.views) {
            if (view.superview) {
                [set addObject:view.superview];
            }
        }
        set;
    });
    for (UIView *view in viewSuperviews) {
        [view setNeedsLayout];
        [view layoutIfNeeded];
    }
}

@end

@implementation LDViewConstraintsStateNode

- (instancetype)initWithStateKey:(id)stateKey
{
    if (self = [self init]) {
        _stateKey = stateKey;
        _views = [[NSMutableArray <UIView *> alloc] init];
        _constraitnsDictionary = [[NSMutableDictionary<NSValue *, ConstraintMake> alloc] init];
    }
    return self;
}

- (void)view:(UIView *)view makeConstraints:(ConstraintMake)block
{
    NSValue *viewValue = [NSValue valueWithNonretainedObject:view];
    if (!self.constraitnsDictionary[viewValue]) {
        [self.views addObject:view];
        self.constraitnsDictionary[viewValue] = block;
    }
}

- (NSMutableArray<MASConstraint *> *)install
{
    NSMutableArray<MASConstraint *> *constraints = [[NSMutableArray alloc] init];
    for (NSValue *viewValue in self.constraitnsDictionary) {
        ConstraintMake block = self.constraitnsDictionary[viewValue];
        UIView *view = [viewValue nonretainedObjectValue];
        [constraints addObjectsFromArray:[view mas_makeConstraints:^(MASConstraintMaker *make) {
            block(view, make);
        }]];
    }
    return constraints;
}

@end
