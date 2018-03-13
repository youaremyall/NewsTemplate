//
//  NSArray+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define valueForArrayFile(filename) [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"] ]

@interface NSArray (Extension)

/**
 * @brief 数组转化为JSON字符串
 * @param array
 */
+ (NSString * _Nullable)arrayToJSONString:(NSArray * _Nonnull)array;

/**
 * @brief JSON字符串转化为数组
 * @param jsonString
 */
+ (NSArray * _Nullable)arrayFromJSONString:(NSString * _Nonnull)jsonString;

@end
