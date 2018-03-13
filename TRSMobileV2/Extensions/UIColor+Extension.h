//
//  UIColor+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/14.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

/**
 * @brief 16进制转颜色值, 常用于web颜色值码(除用于web页面解析, 其他地方不建议采用)
 * @param color
 * @return
 */
+ (UIColor * _Nonnull)colorWithHexString:(NSString * _Nonnull)color;

/**
 * @brief 16进制转颜色值, 常用于web颜色值码(除用于web页面解析, 其他地方不建议采用)
 * @param color
 * @param alpha
 * @return
 */

+ (UIColor * _Nonnull)colorWithHexString:(NSString * _Nonnull)color alpha:(float)alpha;

/**
 * @brief 随机颜色值带Alpha值
 * @param alpha
 * @return
 */
+ (UIColor * _Nonnull)colorRandomWithAlpha:(CGFloat)alpha;

/**
 * @brief 16进制转颜色值
 * @param rgbValue
 * @return
 */
+ (UIColor * _Nonnull)colorWithRGB:(NSInteger)rgbValue;

/**
 * @brief 16进制转颜色值带Alpha值
 * @param rgbValue
 * @param alpha
 * @return
 */
+ (UIColor * _Nonnull)colorWithRGB:(NSInteger)rgbValue alpha:(CGFloat)alpha;

/**
 * @brief 16进制转颜色值带亮度
 * @param color
 * @param brightness
 * @return
 */
+ (UIColor * _Nonnull)colorWithBrightness:(UIColor * _Nonnull)color brightness:(CGFloat)brightness;

/**
 * @brief 混合色 factor：混合因子
 * @param color
 * @param blendedColor
 * @param factor
 * @return
 */
+ (UIColor * _Nonnull)colorWithBlendedColor:(UIColor * _Nonnull)color blendedColor:(UIColor * _Nonnull)blendedColor factor:(CGFloat)factor;

/**
 * @brief 由颜色得到RGBA数值
 * @param color
 * @return
 */
+ (uint32_t)rgbaValue:(UIColor * _Nonnull)color;

/**
 * @brief 由颜色得到RGBA描述
 * @param color
 * @return
 */
+ (NSString * _Nonnull)stringValue:(UIColor * _Nonnull)color;

@end
