//
//  UIRegisterViewController.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRegister2ViewController.h"

@interface UIRegisterViewController : UIViewController

/**
 * 界面操作标识
 */
@property (assign, nonatomic) UIPersonalEvent event;

/**
 * 手机号码
 */
@property (strong, nonatomic) NSString *_Nonnull mobile;

@end
