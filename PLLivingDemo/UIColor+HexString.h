//
//  UIColor+HexString.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/21.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;

@end
