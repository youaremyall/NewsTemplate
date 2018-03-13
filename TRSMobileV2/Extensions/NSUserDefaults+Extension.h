//
//  NSUserDefaults+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/7.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SettingType) {
    
    SettingTypeFontFamily = 0x00,   //字体设置
    SettingTypeFontSize,            //正文字号
    SettingTypeAutoPlayVideo,       //自动播放视频
    SettingTypeOnlyWiFiLoadImages,  //仅WiFi网络加载图片
    SettingTypePushReceive,         //接收推送
    SettingTypeCommentNoUser,       //匿名评论
    SettingTypeNightMode            //夜间模式
};

@interface NSUserDefaults (Extension)

/**
 * @brief 获取系统当前语言
 * @return NSString对象
 */
+ (NSString * _Nonnull)systemLanguage;

/**
 * @brief 设置对象到NSUserDefaluts中保存
 * @param obj : 存储对象
 * @param key : 存储键值
 * @return
 */
+ (BOOL)setObjectForKey:(id _Nonnull)obj key:(NSString * _Nonnull)key;

/**
 * @brief 存储设置对象值
 * @param value : 存储对象
 * @param type : 系统设置类型
 * @return 无
 */
+ (void)setSettingValue:(id _Nonnull)value type:(SettingType)type;

/**
 * @brief 读取设置对象值
 * @param type : 系统设置类型
 * @return 无
 */
+ (id _Nonnull)settingValueForType:(SettingType)type;

@end
