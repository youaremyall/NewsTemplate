//
//  UIPersonalProfileViewController.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPersonalProfileViewController : UIViewController

/**
 * @brief 用户退出回调
 */
@property (copy, nonatomic) void (^logoutBlock)(BOOL ssuccess);

@end
