//
//  NSArray+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

/**
 * @brief 数组转化为JSON字符串
 * @param array
 */
+ (NSString * _Nullable)arrayToJSONString:(NSArray * _Nonnull)array {

    NSString *jsonString = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if(error) {
        NSLog(@"数组转化为JSON字符串错误: %@", error.localizedDescription);
    }
    else {
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

/**
 * @brief JSON字符串转化为数组
 * @param jsonString
 */
+ (NSArray * _Nullable)arrayFromJSONString:(NSString * _Nonnull)jsonString {

    NSArray *array = nil;
    NSError *error = nil;
    
    if(jsonString && ![jsonString isEqualToString:@""]) {
        
        // 增加在,} ,]符号之前多了一个逗号的非标准json字符过滤处理
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@",}" withString:@"}"];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
        
        // 增加回车换行制表符过滤处理
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if(data && data.length) {
            array = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
            if(error) {
                NSLog(@"JSON字符串转化为数组错误: %@", error.localizedDescription);
            }
        }
    }
    
    return array;
}

@end
