//
//  NetworkRequest.h
//  TRSSDK
//
//  Created by 张张凯 on 16/6/22.
//  Copyright © 2016年 zhangkai. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TRSOperationInfo.h"
#import "EventInfo.h"
@interface TRSRequest : NSObject

#pragma mark 通用方法
/**
 *  获取用APP的信息
 *  @param appKey    收到的分发的APPKey
 *  @param appID     收到分发的APPID
 *  @param channel   APP的发布渠道，例如“APP Store”
 */
+ (void)setAppKey:(NSString *)appKey setAppID:(NSString *)appID andChannel:(NSString *)channel;

/**
 *  获取用户经纬度
 */
+ (void)getLongitude:(NSString *)longitude andLatitude:(NSString *)latitude;


#pragma mark 1.5.+方法

/** 统计用户登录及唯一标识信息 
 *  @param statisticsURL 统计路径
 *  @param loginUser     用户登录名
 *  @param deviceID      对方传的唯一标识
 */
+ (void)statisticsURL:(NSString *)statisticsURL loginUser:(NSString *)loginUser andDeviceID:(NSString *)deviceID;

/**
 *  APP在debug调试时调用isDebug为YES，SDK发送机制变逐页发送并打印采集数据。
*/
+ (void)debugEnable:(BOOL)isDebug;

/**
 * 在页面打开的时候调用，获取页面访问时间
 */
+ (void)beginLogPageView;

/**
 * 数据统计，未统计事件时长
*/
+ (void)TRSRecordGeneral:(TRSOperationInfo *)messsageInfo;

/**
 * 数据统计，统计事件时长
 */
+ (void)TRSRecordGeneralWithDuration:(TRSOperationInfo *)messsageInfo;

/**
 *  @param deviceID   新设备码
 *  @param oldDeviceID   老设备码
 */
+ (void)sendAppSelfDeviceID:(NSString *)deviceID oldDeviceID:(NSString *)oldDeviceID;




#pragma mark 1.4.0方法

/** 统计用户登录及唯一标识信息
 *  @param statisticsURL 统计路径
 *  @param loginUser     用户登录名
 *  @param deviceID      对方传的唯一标识
 */
+ (void)statisticsURL:(NSString *)statisticsURL loginUser:(NSString *)loginUser andDeveceID:(NSString *)deviceID __attribute__((deprecated("方法已过期")));

/**
 * 数据统计，未统计事件时长
 */
+ (void)recordGeneral:(EventInfo *)messsageInfo __attribute__((deprecated("方法已过期")));

/**
 * 数据统计，统计事件时长
 */
+ (void)recordGeneralWithDuration:(EventInfo *)messsageInfo __attribute__((deprecated("方法已过期")));





@end
