//
//  NSDictionary+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define valueForDictionaryFile(filename) [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"] ]

@interface NSDictionary (Extension)

/**
 * @brief 字典转化为JSON字符串
 */
+ (NSString * _Nullable)dictionaryToJSONString:(NSDictionary * _Nonnull)dictionary;

/**
 * @brief  JSON字符串转化为字典
 */
+ (NSDictionary * _Nullable)dictionaryFromJSONString:(NSString * _Nonnull)jsonString;

/**
* @brief 根据虚拟的键字段获取字典的值，用于由键不固定而需要获取键值的情况
 */
- (NSString * _Nonnull)objectForVitualKey:(NSString * _Nonnull)key;

@end
