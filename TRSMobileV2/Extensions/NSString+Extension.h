//
//  NSString+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/15.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface NSString (Extension)

/**
 * @brief NSData数据转换为NSString字符串
 * @param data
 */
+ (NSString * _Nullable)stringFromUTF8Data:(NSData * _Nonnull)data;

/**
 * @brief NSData数据转换为NSString字符串
 * @param data
 * @param encoding
 */
+ (NSString * _Nullable)stringFromCFEncodingData:(NSData * _Nonnull)data encoding:(CFStringEncodings)encoding;

/**
 * @brief 格式化输出NSString或NSNumber对象
 * @param object
 */
+ (NSString * _Nonnull)stringFormatValue:(id _Nonnull)object;

/**
 * @brief 根据文件大小bytes字节转化为带单位的可读大小描述
 * @param bytes
 */
+ (NSString * _Nonnull)fileSizeForBytes:(long long)bytes;

/**
 * @brief 计算中英文混排的字符串长度
 * @param string
 */
+ (NSInteger)stringLength:(NSString * _Nonnull)string;

/**
 * @brief 手机号码字符过滤
 * @param mobile
 */
+ (NSString * _Nonnull)mobilePhoneFilter:(NSString * _Nonnull)mobile;

/**
 * @brief 判断手机号码时候有效
 * @param mobile
 */
+ (BOOL)isValidMobilePhone:(NSString * _Nonnull)mobile;

/**
 * @brief 根据生日计算星座
 * @param month
 * @param day
 */
+ (NSString * _Nonnull)getTowerWithMonth:(NSInteger)month day:(NSInteger)day;

/**
 * @brief 根据出生年月日计算当前年龄
 * @param year
 * @param month
 * @param day
 */
+ (NSString * _Nonnull)ageValue:(NSString * _Nonnull)year month:(NSString * _Nonnull)month day:(NSString * _Nonnull)day;

/**
 * @brief 距离显示
 * @param distance
 */
+ (NSString * _Nonnull)distanceValue:(NSString * _Nonnull)distance;

/**
 * @brief 根据星期几获取对应的中文描述
 * @param week
 */
+ (NSString * _Nonnull)getWeekByWeekday:(int)weekday;

/**
 * @brief 根据当前时间得到星期几
 * @param 无
 */
+ (NSInteger)weekDay;

/**
 * @brief 根据播放时间长度格式化为小时分钟表示
 *
 */
+ (NSString * _Nonnull)videoPlayTimeValue:(double)time;

/**
 * @brief 时间字符串格式为可读性的时间描述显示
 * @param dateString
 */
+ (NSString * _Nonnull)timeValue:(NSString * _Nonnull)dateString;

/**
 * @brief 获取网页内的所有图片
 * @param webview
 */
+ (void)getImagesFromWebView:(WKWebView *_Nonnull)webView completion:(void (^ _Nullable)(NSArray * _Nonnull imageUrls))completion;

/**
 * @brief 判断图片链接是否有效
 */
+ (BOOL)isValidImageUrl:(NSString * _Nonnull)url;

/**
 * @berif 过滤掉HTML字符
 */
+ (NSString * _Nullable)fliterHTML:(NSString * _Nullable)str;

/**
 * @brief 判断字符串是否包含字符串
 */
- (BOOL)hasSubString:(NSString * _Nonnull)substr;

/**
 * @brief 计算字体大小
 */
- (CGSize)sizeWithFont:(UIFont * _Nonnull)font maxSize:(CGSize)maxSize;

@end


@interface NSString (Util)

/**
 * @brief sha1加密
 */
+ (NSString * _Nonnull)sha1:(NSString * _Nonnull)str;

/**
 * @brief md5加密
 */
+ (NSString * _Nonnull)md5:(NSString * _Nonnull)str;

/**
 * @brief des加密或解密
 */
+ (NSString * _Nullable)des:(NSString * _Nonnull)str key:(NSString * _Nonnull)key isEncrypt:(BOOL)isEncrypt;

@end

@interface NSString (IDS)

/**
 * @brief IDS 加密算法
 */
+ (NSString * _Nullable)IDSEncrypt:(NSString * _Nonnull)str key:(NSString * _Nonnull)key;

/**
 * @brief IDS 解密算法
 */
+ (NSString * _Nullable)IDSDecrypt:(NSString* _Nonnull)str key:(NSString * _Nonnull)key;

/**
 * @brief 字符串转换为16进制字节数组
 */
+ (NSData * _Nonnull)convertHexStrToData:(NSString * _Nonnull)str;

/**
 * @brief 16进制字节数组转换为字符串
 */
+ (NSString * _Nonnull)convertDataToHexStr:(NSData * _Nonnull)data;

@end
