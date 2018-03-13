//
//  UIColor+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/14.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor * _Nonnull)colorWithHexString:(NSString * _Nonnull)color alpha:(float)alpha {
    
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

+ (UIColor * _Nonnull)colorWithHexString:(NSString * _Nonnull)color {
    
    return [UIColor colorWithHexString:color alpha:1.0];
}

+ (UIColor *)colorRandomWithAlpha:(CGFloat)alpha {
    
    CGFloat red =  (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor * _Nonnull)colorWithRGB:(NSInteger)rgbValue alpha:(CGFloat)alpha {
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha];
}

+ (UIColor * _Nonnull)colorWithRGB:(NSInteger)rgbValue {
    return [UIColor colorWithRGB:rgbValue alpha:1.0];
}

+ (UIColor * _Nonnull)colorWithBrightness:(UIColor * _Nonnull)color brightness:(CGFloat)brightness {
    
    brightness = MAX(brightness, 0.0f);
    
    CGFloat rgba[4];
    [UIColor getRGBAComponents:color rgba:rgba];
    
    return [UIColor colorWithRed:rgba[0] * brightness
                           green:rgba[1] * brightness
                            blue:rgba[2] * brightness
                           alpha:rgba[3]];
}

+ (UIColor * _Nonnull)colorWithBlendedColor:(UIColor * _Nonnull)color blendedColor:(UIColor * _Nonnull)blendedColor factor:(CGFloat)factor {
    
    factor = MIN(MAX(factor, 0.0f), 1.0f);
    
    CGFloat fromRGBA[4], toRGBA[4];
    [UIColor getRGBAComponents:color rgba:fromRGBA];
    [UIColor getRGBAComponents:blendedColor rgba:toRGBA];
    
    return [UIColor colorWithRed:fromRGBA[0] + (toRGBA[0] - fromRGBA[0]) * factor
                           green:fromRGBA[1] + (toRGBA[1] - fromRGBA[1]) * factor
                            blue:fromRGBA[2] + (toRGBA[2] - fromRGBA[2]) * factor
                           alpha:fromRGBA[3] + (toRGBA[3] - fromRGBA[3]) * factor];
}

+ (void)getRGBAComponents:(UIColor * _Nonnull)color rgba:(CGFloat[4])rgba {
    
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = components[0];
            rgba[1] = components[0];
            rgba[2] = components[0];
            rgba[3] = components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = components[0];
            rgba[1] = components[1];
            rgba[2] = components[2];
            rgba[3] = components[3];
            break;
        }
        case kCGColorSpaceModelCMYK:
        case kCGColorSpaceModelDeviceN:
        case kCGColorSpaceModelIndexed:
        case kCGColorSpaceModelLab:
        case kCGColorSpaceModelPattern:
        case kCGColorSpaceModelUnknown:
        {
            //unsupported format
            NSLog(@"Unsupported color model: %i", model);
            rgba[0] = 0.0f;
            rgba[1] = 0.0f;
            rgba[2] = 0.0f;
            rgba[3] = 1.0f;
            break;
        }
    }
}

+ (uint32_t)rgbaValue:(UIColor * _Nonnull)color {
    
    CGFloat rgba[4];
    [UIColor getRGBAComponents:color rgba:rgba];
    uint8_t red = rgba[0]*255;
    uint8_t green = rgba[1]*255;
    uint8_t blue = rgba[2]*255;
    uint8_t alpha = rgba[3]*255;
    return (red << 24) + (green << 16) + (blue << 8) + alpha;
}

+ (NSString * _Nonnull)stringValue:(UIColor * _Nonnull)color {
    
    //include alpha component
    return [NSString stringWithFormat:@"#%.8x", [UIColor rgbaValue:color] ];
}

@end
