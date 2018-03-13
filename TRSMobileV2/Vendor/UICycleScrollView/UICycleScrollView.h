//
//  XLCycleScrollView.h
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@protocol UICycleScrollViewDatasource;
@interface UICycleScrollView : UIView

@property (nonatomic, assign) id<UICycleScrollViewDatasource>datasource;
@property (readonly,  assign) NSInteger curPage;
@property (readonly,  assign) NSInteger totalPages;
@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 * @brief 重新加载
 */
- (void)reloadData;

@end

@protocol UICycleScrollViewDatasource <NSObject>

@required

/**
 * @brief 总页数
 */
- (NSInteger)numberOfPages:(UICycleScrollView *)csView;

/**
 * @brief 每页的数据
 */
- (NSDictionary *)pageAtIndex:(UICycleScrollView *)csView index:(NSInteger)index;

/**
 * @brief 选中事件
 */
- (void)select:(UICycleScrollView *)csView index:(NSInteger)index;

@optional

/**
 * @brief 文字颜色
 */
- (UIColor *)titleColor:(UICycleScrollView *)csView;

/**
 * @brief 文字底层背景阴影颜色
 */
- (UIColor *)backgroundShadowColor:(UICycleScrollView *)csView;

/**
 * @brief 文字底层背景图
 */
- (UIImage *)backgroundShadowImage:(UICycleScrollView *)csView;

@end
