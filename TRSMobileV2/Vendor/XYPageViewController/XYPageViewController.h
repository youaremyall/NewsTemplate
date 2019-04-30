//
//  XYPageViewController.h
//  XYHiRepairs
//
//  Created by krystal on 2018/7/9.
//  Copyright © 2018年 Kingnet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XYPageConfigration;

typedef void (^SelectItemBlock)(NSInteger index);

@interface XYPageViewController : UIViewController 


/**
 初始化方法
 @param controllers 子控制器
 @param titles 标题
 @param config 配置信息
 */
+ (instancetype)pageViewControllerWithControllers:(NSArray *)controllers
                                           titles:(NSArray *)titles
                                           config:(XYPageConfigration *)config;


/**
 *  当前PageScrollViewVC作为子控制器
 *
 *  @param parentViewControler 父类控制器
 */
//- (void)addSelfToParentViewController:(UIViewController *)parentViewControler;


/**
 *  从父类控制器里面移除自己（PageScrollViewVC）
 */
//- (void)removeSelfViewController;

/**
 选中页码
 @param pageIndex 页面下标
 */
- (void)setSelectedPageIndex:(NSInteger)pageIndex;


/// 控制器数组
@property (nonatomic, strong) NSMutableArray *controllersM;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, copy) SelectItemBlock selectItemBlock;

@property (nonatomic, assign) BOOL isScrollPageVC;


#pragma mark - initialize

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;




@end
