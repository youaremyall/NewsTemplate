//
//  UINavbarPicker.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/12.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavbarPicker : UIView

/**
 * 传入参数
 */
@property (strong, nonatomic) NSArray  * _Nonnull titles;

/**
 * 当前选中索引值
 */
@property (readwrite, nonatomic) NSInteger index;

/**
 * 宽度是否相等，默认为YES
 */
@property (assign, nonatomic) BOOL isEqualWidth;

/**
 * 订阅标识，应在设置titles数组前优先调用
 */
@property (assign, nonatomic) BOOL isSubscrible;

/**
 * 仅加载已订阅栏目标识
 */
@property (assign, nonatomic) BOOL isOnlyLoadSubscribled;

/**
 * 订阅按钮图标，应在设置titles数组前优先调用
 */
@property (strong, nonatomic) UIImage * _Nonnull imageSubscrible;

/**
 * 栏目订阅事件
 */
@property (copy, nonatomic) void (^_Nullable subscribleEvent)(void);

/**
 * 子栏目点击回调
 */
@property (copy, nonatomic) void (^_Nullable clickEvent)(NSDictionary * _Nullable dict, NSInteger index);


@end
