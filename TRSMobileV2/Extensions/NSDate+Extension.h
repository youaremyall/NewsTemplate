//
//  NSDate+Extensions.h
//  TRSMobile
//
//  Created by  TRS on 14/12/11.
//  Copyright (c) 2014年 TRS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

/**
 *	@brief	获取NSDate的年份部分
 *	@param 	date 	日期对象
 *	@return	年份
 */
+ (NSInteger)getYear:(NSDate * _Nonnull)date;

/**
 *	@brief	获取NSDate的月份部分
 *	@param 	date 	日期对象
 *	@return	月份
 */
+ (NSInteger)getMonth:(NSDate * _Nonnull)date;

/**
 *	@brief	获取NSDate的日期部分
 *	@param 	date 	日期对象
 *	@return	日期
 */
+ (NSInteger)getDay:(NSDate * _Nonnull)date;

/**
 *	@brief	获取NSDate的小时部分
 *	@param 	date 	日期对象
 *	@return	小时
 */
+ (NSInteger)getHour:(NSDate * _Nonnull)date;

/**
 *	@brief	获取NSDate的分钟部分
 *	@param 	date 	日期对象
 *	@return	分钟
 */
+ (NSInteger)getMinute:(NSDate * _Nonnull)date;

/**
 *	@brief	获取NSDate的秒部分
 *	@param 	date 	日期对象
 *	@return	秒
 */
+ (NSInteger)getSecond:(NSDate * _Nonnull)date;

/**
 *	@brief	根据年月日返回日期
 *	@param 	year 	年份
 *	@param 	month 	月份
 *	@param 	date 	日期
 *	@param 	hour 	小时
 *	@param 	minute 	分钟
 *	@param 	second 	秒
 *	@return	日期对象
 */
+ (NSDate *  _Nonnull)dateByYear:(NSInteger)year
                         month:(NSInteger)month
                          date:(NSInteger)date
                          hour:(NSInteger)hour
                        minute:(NSInteger)minute
                        second:(NSInteger)second;

/**
 *	@brief	转化字符串为日期
 *	@param 	dateString 	日期字符串
 *	@param 	format 	日期格式字符串
 *	@return	日期对象
 */
+ (NSDate *  _Nonnull)dateByDateString:(NSString * _Nonnull)dateString format:(NSString * _Nonnull)format;

/**
 *	@brief	转化字符串为日期
 *	@param 	dateString 	日期字符串
 *	@param 	format 	日期格式字符串
 *	@param 	locale 	本地化参数
 *	@return	日期对象
 */
+ (NSDate * _Nonnull)dateByDateString:(NSString * _Nonnull)dateString format:(NSString * _Nonnull)format locale:(NSLocale * _Nonnull)locale;

/**
 *	@brief	转化日期为字符串 NSDate->NSString
 *	@param 	date 	日期对象
 *	@param 	format 	日期格式字符串
 *	@return	日期字符串
 */
+ (NSString * _Nonnull)dateStringByDate:(NSDate * _Nonnull)date format:(NSString * _Nonnull)format;

/**
 *	@brief	转化日期时间戳为字符串
 *	@param 	interval 	时间戳值
 *	@return	日期字符串 (如1970-01-01格式)
 */
+ (NSString * _Nonnull)dateStringByTimestamp:(double)timestamp format:(NSString * _Nonnull)format;

@end
