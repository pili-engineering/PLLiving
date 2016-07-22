//
//  UIColor+HexString.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/21.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"0x%@", stringToConvert]];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    if (stringToConvert.length == 6) {
        return [UIColor colorWithRGBHex:hexNum];
    } else if (stringToConvert.length == 8) {
        return [UIColor colorWithARGBHex:hexNum];
    } else {
        return [UIColor blackColor];
    }
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    int red = (hex >> 16) & 0xFF;
    int green = (hex >> 8) & 0xFF;
    int blue = (hex) & 0xFF;
    return [UIColor colorWithRed:red / 255.0f
                           green:green / 255.0f
                            blue:blue / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithARGBHex:(UInt32)hex
{
    int alpha = (hex >> 24) & 0xFF;
    int red = (hex >> 16) & 0xFF;
    int green = (hex >> 8) & 0xFF;
    int blue = (hex) & 0xFF;
    return [UIColor colorWithRed:red / 255.0f
                           green:green / 255.0f
                            blue:blue / 255.0f
                           alpha:alpha / 255.0f];
}

@end
