//
//  UIDevice+Extension.h
//  UFun
//
//  Created by wujianjun on 11-7-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SAMKeychain.h"

/**
 * @brief 判断当前设备是否为模拟器
 * @param 无
 */
bool isSimulator(void);

/**
 * @brief 判断当前设备是否为iPad
 * @param 无
 */
bool isiPad(void);

/**
 * @brief 获取当前设备屏幕宽度
 * @param 无
 */
float screenWidth(void);

/**
 * @brief 获取当前设备屏幕高度
 * @param 无
 */
float screenHeight(void);

/**
 * @brief 获取当前设备版本号
 * @param 无
 */
float deviceVersion(void);

/**
 * @brief 获取当前设备Id
 * @param 无
 */
NSString * _Nonnull getDeviceId(void);

/**
 * @brief 默认启动图
 * @param 无
 */
NSString * _Nonnull launchImage(void);

/**
 * @brief 播放简短音频文件
 * @param url : 文件地址
 */
void audioPlayWithURL(NSURL * _Nonnull url);

/**
 * @brief 播放振动
 * @param 无
 */
void audioPlayVibrate(void);

/**
 * @brief 拨打电话号码
 * @param phone : 电话号码
 * @param inView : 目标视图
 */
void callPhone(NSString * _Nonnull mobile, UIView * _Nonnull view);
