//
//  LDTouchTransparentView.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/20.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDTouchTransparentView.h"

@implementation LDTouchTransparentView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.maskAllScreen) {
        return [super hitTest:point withEvent:event];
    } else {
        // 此时 LDTouchTransparentView 仅仅当 touch 到它的 subview 的时候才会响应手势。
        // 仅仅触碰其本身，等价于穿透它直接触碰到它后面的 view。
        for (UIView *view in [self.subviews reverseObjectEnumerator]) {
            CGPoint subPoint = [view convertPoint:point fromView:self];
            UIView *hitView = [view hitTest:subPoint withEvent:event];
            if (hitView) {
                return hitView;
            }
        }
    }
    return nil;
}

@end
