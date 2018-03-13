//
//  TRSMobile.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/10.
//  Copyright © 2016年 liaojingyu. All rights reserved.
//

#ifndef TRSMobile_h
#define TRSMobile_h

/**与应用相关的扩展宏定义文件*/
/*********************************************************************/

/**
 * 应用主题颜色
 */
#define UIColorThemeDefault     0xe43d2c

/**
 * 颜色定义
 */
#define UIColorImageBackgrond   0xefefef

/**
 * 通用背景图片
 */
#define UIGlobalImageBackground @"https://b-ssl.duitang.com/uploads/item/201608/03/20160803215822_zUPEL.thumb.700_0.jpeg"

/*********************************************************************/

/**
 * 我的阅读开关
 */
#define isMyReadingEnable       1

/**
 * 我的消息开关
 */
#define isMyMessageEnable       0

/**
 * 离线阅读开关
 */
#define isOfflineReadEnable     0

/*************************************常用参数************************************/
//拼接字符串
#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]


/**
 *  导航控制器高度
 */
#define NavcHeight 64.0
/**
 *  tarbar的高度
 */
#define TarBarHeight  49.0
#define TarBarPlus  64.0

// 字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )

// 字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)

// 数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)

// 是否为空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

// 获取沙盒路径
#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#if TARGET_OS_IPHONE
// 真机
#endif
#if TARGET_IPHONE_SIMULATOR
// 模拟器
#endif


// 获取一段时间间隔
#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define kEndTime  NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start)

/*************************************获取系统对象************************************/


#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kApplication        [UIApplication sharedApplication]
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kNotificationCenter [NSNotificationCenter defaultCenter]

/*************************************获取屏幕宽高************************************/


#define kwidth    ([[UIScreen mainScreen] bounds].size.width)
#define kheight   ([[UIScreen mainScreen] bounds].size.height)
#define kScreen_Bounds  [UIScreen mainScreen].bounds


/*************************************强弱引用***************************************/
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;


/*************************************View圆角和加边框********************************/
//View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

/*************************************字体适配宏*************************************/
/**
 *  字体适配宏
 */
//不同屏幕尺寸字体适配
#define CHINESE_FONT_NAME  @"Heiti SC"
#define CHINESE_FONT_BOLD  @"Helvetica-Bold"
#define CHINESE_SYSTEM(x) [UIFont fontWithName:CHINESE_FONT_NAME size:x]
#define CHINESE_Bold(x) [UIFont fontWithName:CHINESE_FONT_BOLD size:x]
#define kScreenWidthRatio  (kwidth / 414.0)
#define kScreenHeightRatio (kheight / 736.0)
#define AdaptedWidth(x)  ceilf((x) * kScreenWidthRatio)
#define AdaptedHeight(x) ceilf((x) * kScreenHeightRatio)
#define AdaptedFontSize(R)     CHINESE_SYSTEM(AdaptedWidth(R))
#define AdaptedBoldFontSize(R)     CHINESE_Bold(AdaptedWidth(R))
/**
 * 应用主题颜色
 */
#define UIColorThemeDefault     0xe43d2c
/*************************************GCD******************************************/
//G－C－D

#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)

#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)


/*************************************颜色*******************************************/


#define randowColor [UIColor colorWithRed:arc4random() % 256 / 255.0 green: arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];

#define kwhiteColor  [UIColor whiteColor]

/*************************************缩放比********************************************/

// 缩放比
#define kScalewidth iphoneWidth / 375

#define kScaleheigth iphoneHeigh / 667

/*************************************读取图片********************************************/
// 读取图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]


/*************************************版本判断*******************************************/
///IOS 版本判断
#define IOSAVAILABLEVERSION(version) ([[UIDevice currentDevice] availableVersion:version] < 0)
// 当前系统版本
#define CurrentSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]
//当前语言
#define CurrentLanguage (［NSLocale preferredLanguages] objectAtIndex:0])


//单例化一个类
#define SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}



#endif /* TRSMobile_h */
