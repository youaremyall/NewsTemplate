//
//  UIRegister2ViewController.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/9.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *_Nonnull const didPersonalInfoChangeNotification;

typedef NS_ENUM(NSInteger, UIPersonalEvent) {
    UIPersonalEventRegister = 0x00,//普通注册
    UIPersonalEventForgetPassword, //找回密码
    UIPersonalEventBindMobile,     //绑定手机
};

@interface UIRegister2ViewController : UIViewController

/**
 * 界面操作标识
 */
@property (assign, nonatomic) UIPersonalEvent event;

/**
 * 手机号码
 */
@property (strong, nonatomic) NSString *_Nonnull mobile;

@end
