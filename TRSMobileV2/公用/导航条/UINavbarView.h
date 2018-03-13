//
//  UINavbarView.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/11.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavbarView : UIView

/**
 * 背景图
 */
@property (weak, nonatomic) IBOutlet UIImageView *barBackground;

/**
 * 左侧按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *barLeft;

/**
 * 右侧按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *barRight;

/**
 * 中间标题
 */
@property (weak, nonatomic) IBOutlet UILabel *barTitle;

/**
 * 点击回调事件
 */
@property (copy, nonatomic) void (^clickEvent)(NSDictionary *dict, NSInteger index);

@end
