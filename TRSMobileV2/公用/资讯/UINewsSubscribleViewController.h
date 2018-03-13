//
//  UINewsSubscribleViewController.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/14.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINewsSubscribleItem.h"

@interface UINewsSubscribleViewController : UIViewController

/**
 * @brief 展示订阅界面
 * @param parent : 显示的父类控制器
 * @param channels : 新闻栏目数据
 * @param y : 订阅界面开始显示的y坐标
 * @param h : 订阅界面切换栏目的高度
 * @param changeBlock : 订阅栏目发生更改回调
 * @param clickBlock : 订阅栏目点击回调
 * @return 无
 */
+ (void)showInVC:(UIViewController * _Nonnull )parent
        channels:(NSArray * _Nonnull)channels
               y:(CGFloat)y
               h:(CGFloat)h
     changeBlock:(void (^_Nonnull)(NSArray * _Nonnull channels))changeBlock
      clickBlock:(void (^_Nonnull)(NSInteger index))clickBlock;

@end
