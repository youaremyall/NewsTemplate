//
//  AVOSCloudSNS.h
//  AVOSCloudSocial
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

//! Project version number for AVOSCloudSocial.
FOUNDATION_EXPORT double AVOSCloudSocialVersionNumber;

//! Project version string for AVOSCloudSocial.
FOUNDATION_EXPORT const unsigned char AVOSCloudSocialVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LeanCloudSocial/PublicHeader.h>

#import "AVUser+SNS.h"

/**
 *  AVOSCloudSNS目前支持的平台类型
 */
typedef NS_ENUM(int, AVOSCloudSNSType){
    /// 新浪微博
    AVOSCloudSNSSinaWeibo  =1,
    
    /// QQ
    AVOSCloudSNSQQ         =2,
    
    /// 微信
    AVOSCloudSNSWeiXin      =3,
};

/**
 *  AVOSCloudSNS错误码
 */

typedef NS_ENUM(int, AVOSCloudSNSErrorCode){
    /// 用户取消
    AVOSCloudSNSErrorUserCancel  =1,
    
    /// 登录失败
    AVOSCloudSNSErrorLoginFail   =2,
    
    /// 无绑定用户
    AVOSCloudSNSErrorNeedLogin   =3,
    
    /// Token过期
    AVOSCloudSNSErrorTokenExpired=4,
    
    /// 操作不支持。当微信没有安装时，调用 -[loginWithCallback:platform] 会返回该错误，暂不支持微信网页登录
    AVOSCloudSNSErrorCodeNotSupported = 5,
    
    /// 无效的第三方数据
    AVOSCloudSNSErrorCodeAuthDataError = 6,
};

/**
 *  AVOSCloudSNS错误域
 */
extern NSString * const AVOSCloudSNSErrorDomain;

/**
 *  AVOSCloudSNS请求回调
 *
 *  @param object 请求成功返回的内容
 *  @param error  请求失败返回的内容
 */
typedef void (^AVSNSResultBlock)(id object, NSError *error);
typedef void (^AVSNSProgressBlock)(float percent);


/**
 *  AVOSCloudSNS 是一个轻量级的社交平台助手
 *  几行代码就可以实现登录和发布内容
 */
@interface AVOSCloudSNS : NSObject

/**
 *  设置平台所需要的参数
 *
 *  @warning 如果不进行设置, 则用`AVOSCloud`进行登录认证.
 *
 *  @param type         平台类型
 *  @param appkey       该平台分配的AppKey
 *  @param appsec       该平台分配的AppSecret
 *  @param redirect_uri 该平台上设置的回调地址 (QQ可以nil, 因为QQ没有这个设置选项. 新浪微博必填!)
 */
+(void)setupPlatform:(AVOSCloudSNSType)type
          withAppKey:(NSString*)appkey andAppSecret:(NSString*)appsec andRedirectURI:(NSString*)redirect_uri;

/**
 *  相应的 App 是否有安装，如果有安装的话，说明可以用 SSO 跳转登录。没有安装的话，QQ 和微博将跳转至网页登录，微信暂时不支持网页登录，请隐藏微信按钮。
 *  @param type 支持 QQ、WeiXin、Weibo
 *  @return
 */
+ (BOOL)isAppInstalledForType:(AVOSCloudSNSType)type;

/**
 *  用社交平台登录, 并获取手动显示登录界面
 *  @warning 需要在回调后手动关闭此UIViewController.
 *  @param  callback    登录结果回调
 *
 *  @return 用于显示登录界面的UIViewController,如果可以SSO登录 则返回nil.
 */
+(UIViewController*)loginManuallyWithCallback:(AVSNSResultBlock)callback;


/**
 *  用指定的社交平台登录, 并获取手动显示登录界面
 *  @warning 需要在回调后手动关闭此UIViewController.
 *  @param  type        指定平台类型
 *  @param  callback    登录结果回调
 *
 *  @return 用于显示登录界面的UIViewController,如果可以SSO登录 则返回nil.
 */
+(UIViewController*)loginManuallyWithCallback:(AVSNSResultBlock)callback toPlatform:(AVOSCloudSNSType)type;

/**
 *  用社会化平台登录,并自动弹出登录界面
 *
 *  @discussion 如果配置了SSO的相关数据会自动尝试用SSO来打开官方应用登录,如果不成功则用传统的方式在本App界面中完成登录过程
 *  @warning 如果主窗口有`rootViewController`,则会自动通过presentModalViewController打开. **注意:** presentModalViewController与正在进行的其它系统动画同时出现时会在Log里出现`Warning: ... while a presentation or dismiss is in progress!`类似的警告,但是不会影响使用
 *  @param  callback    登录结果回调
 *
 */
+(void)loginWithCallback:(AVSNSResultBlock)callback;

/**
 *  用指定的社交平台登录,并自动弹出登录界面
 *
 *  @warning 如果主窗口有`rootViewController`,则会自动通过presentModalViewController打开. **注意:** presentModalViewController与正在进行的其它系统动画同时出现时会在Log里出现`Warning: ... while a presentation or dismiss is in progress!`类似的警告,但是不会影响使用
 *  @param  type        指定平台类型
 *  @param  callback    登录结果回调
 *
 */
+(void)loginWithCallback:(AVSNSResultBlock)callback toPlatform:(AVOSCloudSNSType)type;

/**
 *  通过后台生成的登录url显示登录界面
 *  @warning 需要在回调后手动关闭此UIViewController.
 *  @param  url         后台生成的登录url
 *  @param  callback    登录结果回调
 *
 *  @return 用于显示登录界面的UIViewController.
 */
+(UIViewController *)loginManuallyWithURL:(NSURL *)url callback:(AVSNSResultBlock)callback;

/**
 *  通过后台生成的登录url显示登录界面
 *
 *  @warning 如果主窗口有`rootViewController`,则会自动通过presentModalViewController打开. **注意:** presentModalViewController与正在进行的其它系统动画同时出现时会在Log里出现`Warning: ... while a presentation or dismiss is in progress!`类似的警告,但是不会影响使用
 *  @param  url         后台生成的登录url
 *  @param  callback    登录结果回调
 *
 */
+(void)loginWithURL:(NSURL *)url callback:(AVSNSResultBlock)callback;

/**
 *  分享文字到指定社交平台
 *  @warning 目前只支持新浪微博
 *
 *  @param  text        文字内容
 *  @param  linkUrl     链接地址(可选)
 *  @param  type        指定平台类型
 *  @param  callback    结果回调
 *  @param  progressBlock    进度回调(可选)
 *
 */
+(void)shareText:(NSString*)text andLink:(NSString*)linkUrl toPlatform:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock;


/**
 *  分享文字和图片到指定社交平台
 *  @warning 目前只支持新浪微博
 *
 *  @param  text        文字内容
 *  @param  linkUrl     链接地址(可选)
 *  @param  image       图片 (将会被JPEG压缩0.8)
 *  @param  type        指定平台类型
 *  @param  callback    结果回调
 *  @param  progressBlock    进度回调(可选)
 *
 */
+(void)shareText:(NSString*)text andLink:(NSString*)linkUrl andImage:(UIImage*)image toPlatform:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock;


/**
 *  注销指定的社交平台绑定的账号
 *
 *  @param  type        指定平台类型
 *
 */
+(void)logout:(AVOSCloudSNSType)type;

/**
 *  捕获SSO登录后返回数据
 *
 *  @param url 回调本app的URL
 */
+(BOOL)handleOpenURL:(NSURL *)url;


/**
 *  获取指定的社交平台已经缓存的用户信息
 *
 *  @param  type        指定平台类型
 *  @return 包含用户信息的字典, 如果返回nil则没有绑定的用户. 包括常用字段, 用户ID:`id`, 用户名:`username`, 平台类型:`type`, 头像:`avatar`, 过期时间:`expires_at`, token:`access_token`, 用户原始信息:`raw-user`
 */

+(NSDictionary*)userInfo:(AVOSCloudSNSType)type;

/**
 *  判断指定的社交平台已经缓存的用户信息是否过期
 *
 *  @param  type        指定平台类型
 *  @return 是否过期
 */
+(BOOL)doesUserExpireOfPlatform:(AVOSCloudSNSType)type;


/**
 *  刷新用户授权时间
 *  @discussion 如果当前用户授权没有过期,则无需用户操作, 登录过程一闪而过. 如果授权过期,则需要用户重新授权
 *
 *  @param  type        指定平台类型
 *  @param  callback    登录结果回调
 */
+(void)refreshToken:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback;

#pragma mark - Deprecated

+ (UIViewController*)loginManualyWithCallback:(AVSNSResultBlock)callback AVDeprecated("Use loginManuallyWithCallback: instead");
+ (UIViewController *)loginManualyWithURL:(NSURL *)url callback:(AVSNSResultBlock)callback AVDeprecated("Use loginManuallyWithURL:callback instead.");
+ (UIViewController*)loginManualyWithCallback:(AVSNSResultBlock)callback toPlatform:(AVOSCloudSNSType)type AVDeprecated("Use loginManuallyWithCallback:toPlatform: instead.");

@end

