//
//  SYProgressView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/11/15.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//  https://github.com/potato512/SYProgressView

#import <UIKit/UIKit.h>

@interface SYProgressView : UIView

/// 背景颜色（默认灰色）
@property (nonatomic, strong) UIColor *defaultColor;
/// 进度颜色（默认蓝色）
@property (nonatomic, strong) UIColor *progressColor;
/// 边框线条颜色（默认黑色）
@property (nonatomic, strong) UIColor *lineColor;
/// 边框线条大小（默认1.0）
@property (nonatomic, assign) CGFloat lineWidth;

/// 字体标签（默认字体黑色/居中显示/隐藏）
@property (nonatomic, strong) UILabel *label;

/**
 初始化
 */
- (void)initializeProgress;

@end
