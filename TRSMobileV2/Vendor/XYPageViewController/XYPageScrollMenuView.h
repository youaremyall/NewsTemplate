//
//  XYPageScrollMenuView.h
//  XYHiRepairs
//
//  Created by krystal on 2018/7/9.
//  Copyright © 2018年 Kingnet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XYPageConfigration;

@protocol XYPageScrollMenuViewDelegate <NSObject>

@optional

/// 点击item
- (void)pagescrollMenuViewItemOnClick:(UILabel *)label index:(NSInteger)index;

/// 点击Add按钮
- (void)pagescrollMenuViewAddButtonAction:(UIButton *)button;

@end



@interface XYPageScrollMenuView : UIView

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 初始化YNPageScrollMenuView
 
 @param frame 大小
 @param titles 标题
 @param configration 配置信息
 @param delegate 代理
 @param currentIndex 当前选中下标
 */
+ (instancetype)pagescrollMenuViewWithFrame:(CGRect)frame
                                     titles:(NSArray *)titles
                               configration:(XYPageConfigration *)configration
                                   delegate:(id<XYPageScrollMenuViewDelegate>)delegate
                               currentIndex:(NSInteger)currentIndex;

- (void)adjustItemPositionWithCurrentIndex:(NSInteger)index;

- (void)adjustItemWithProgress:(CGFloat)progress
                     lastIndex:(NSInteger)lastIndex
                  currentIndex:(NSInteger)currentIndex;

- (void)selectedItemIndex:(NSInteger)index
                 animated:(BOOL)animated;

- (void)adjustItemWithAnimated:(BOOL)animated;

@end
