//
//  UILoginViewController.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRegisterViewController.h"

@interface UILoginViewController : UIViewController

/**
 * @brief 显示登录页面
 * @param parent : 显示登录页面的视图
 * @param completion : 用户登录回调
 * @return 无
 */
+ (void)showLoginInVC:(UIViewController * _Nonnull)parent completion:(void (^ _Nullable)(BOOL success))completion;

@end
