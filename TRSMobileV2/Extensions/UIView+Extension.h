//
//  UIView+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/25.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface UIView (CALayer)

/**
 * @brief 设置圆角
 * @param raduis : 半径
 */
- (void)setCornerWithRadius:(CGFloat)radius;

/**
 * @brief 设置边框
 * @param color : 颜色
 * @param width : 宽度
 * @param
 */
- (void)setBorderWithColor:(UIColor * _Nonnull)color borderWidth:(CGFloat)borderWidth;

/**
 * @brief 设置阴影
 * @param color : 颜色
 * @param width : 宽度
 * @param
 */
- (void)setShadowWithColor:(UIColor * _Nonnull)color shadowOpacity:(CGFloat)shadowOpacity shadowOffset:(CGSize)shadowOffset;

/**
 * @brief 设置渐变色
 * @param color : 颜色
 * @param width : 宽度
 * @param
 */
- (void)setGradientWithColors:(NSArray * _Nonnull)gradientColors gradientRect:(CGRect )gradientRect;

@end


@interface UIView  (CGRect)

/**
 * @brief x坐标
 * @return x坐标
 */
- (CGFloat)x;

/**
 * @brief y坐标
 * @return y坐标
 */
- (CGFloat)y;

/**
 * @brief 宽度
 * @return 宽度
 */
- (CGFloat)width;

/**
 * @brief 高度
 * @return 高度
 */
- (CGFloat)height;

/**
 * @brief 设置Y坐标
 * @param x : x坐标
 */
- (void)setX:(CGFloat)x;

/**
 * @brief 设置Y坐标
 * @param y : y坐标
 */
- (void)setY:(CGFloat)y;

/**
 * @brief 设置宽度
 * @param width : 宽度
 */
- (void)setWidth:(CGFloat)width;

/**
 * @brief 设置高度
 * @param width : 宽度
 */
- (void)setHeight:(CGFloat)height;

/**
 * @brief 设置起始点
 * @param origin : 起始点
 */
- (void)setOrigin:(CGPoint)point;

/**
 * @brief 设置大小
 * @param size : 大小
 */
- (void)setSize:(CGSize)size;

@end

@interface UIView (UIGestureRecognizer)

/**
 * @brief 添加点击手势
 */
- (void)addTapGesture:(id _Nonnull)target selector:(SEL _Nonnull)selector;

/**
 * @brief 添加拖动手势
 */
- (void)addPanGesture:(id _Nonnull)target selector:(SEL _Nonnull)selector;

/**
 * @brief 添加长按手势
 */
- (void)addLongPressGesture:(id _Nonnull)target selector:(SEL _Nonnull)selector;

@end

@interface UIView  (UIView_CAAnimation)

/**
 * @brief 类心跳振动动画
 */
- (void)animationHeartBeat;

/**
 * @brief 线性消失动画
 */
- (void)animationCurveEaseOut;

/**
 * @brief 来回抖动动画
 * @param enable
 */
- (void)animationShake:(BOOL)enable;

/**
 * @brief 旋转动画
 * @pram value
 */
- (CABasicAnimation * _Nonnull)animationRotate:(CGFloat)value;

@end

@interface UIView  (UIResponder)

/**
 * @brief 查找响应链FirstResponder
 */
- (UIView * _Nonnull)findFirstResponder;

@end

@interface UIWindow (Extension)

/**
 * @brief 夜间模式
 */
+ (void)enableNightMode:(BOOL)enable;

@end
