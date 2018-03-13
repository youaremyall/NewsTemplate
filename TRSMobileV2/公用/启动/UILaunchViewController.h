//
//  UISplashViewController.h
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2016/3/31.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>


/*广告接口API*/
#define kLaunchAPIUrl       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1520925966765&di=3d3039d3462fe1f00f532455a948eea9&imgtype=0&src=http%3A%2F%2Fimg4.duitang.com%2Fuploads%2Fitem%2F201408%2F12%2F20140812132117_fvJsY.jpeg"

/*外层封装字段*/
#define kLaunchResponse     @"response"

/*广告过期时间*/
#define kLaunchExpireDate   @"expiredDate"

/*广告加载地址*/
#define kLaunchMedia        @"keep.mp4"

/*广告链接地址*/
#define kLaunchUrl          @"url"

@interface UILaunchViewController : UIViewController

/**
 * 程序安装后第一次运行时加载的用户引导图片
 * 若指定传入，在此传入图片名称；若不调用此方法，则会默认从splash.bundle包加载
 * 备注：用户引导图片，只需针对3.5"和5.5"屏幕提供2组图片, 3.5"图片放在2x目录下，5.5"图片放在3x目录下.
 */
@property (nonatomic, retain) NSArray * _Nonnull coverImages;

/**
 * 第一次即将进入应用主视窗事件，在点击进入前调用
 */
@property (nonatomic, copy) void (^_Nonnull willEnterAppBlock)(void);

/**
 * 单例实例
 */
+ (instancetype _Nonnull)sharedInstance;

@end
