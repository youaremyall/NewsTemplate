//
//  AppDelegate.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/7.
//  Copyright © 2016年 liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSDynamicsDrawerViewController, UIAnimationNavigationController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

/**
 * 程序主视窗
 */
@property (strong, nonatomic) UIWindow *window;


/**
 * 中间部分显示的视窗根导航视图
 */
@property (strong, nonatomic) UIAnimationNavigationController   *navTab;

/**
 * 侧滑组件为主视窗根视图,可以滑动内容及边缘pop
 */
@property (strong, nonatomic) MSDynamicsDrawerViewController    *vcDrawer;


@end

