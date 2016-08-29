//
//  LDAppearanceView.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/22.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDAppearanceView.h"

@interface LDAppearanceView ()
@end

@implementation LDAppearanceView

- (instancetype)initWithLayer:(CALayer *)layer
{
    return [self initWithLayers:@[layer]];
}

- (instancetype)initWithLayers:(NSArray <CALayer *> *)layers
{
    if (self = [self init]) {
        for (CALayer *layer in layers) {
            [self.layer addSublayer:layer];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (CALayer *sublayer in self.layer.sublayers) {
        sublayer.frame = self.bounds;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

@end
