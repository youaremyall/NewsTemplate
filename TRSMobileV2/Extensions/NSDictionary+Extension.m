//
//  NSDictionary+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

+ (NSString * _Nullable)dictionaryToJSONString:(NSDictionary * _Nonnull)dictionary {

    NSString *jsonString = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if(error) {
        NSLog(@"字典转化为JSON字符串错误: %@", error.localizedDescription);
    }
    else {
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

+ (NSDictionary * _Nullable)dictionaryFromJSONString:(NSString * _Nonnull)jsonString {

    NSDictionary *dictionary = nil;
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
            dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
            if(error) {
                NSLog(@"JSON字符串转化为字典错误: %@", error.localizedDescription);
            }
        }
    }
    
    return dictionary;
}

- (NSString * _Nonnull)objectForVitualKey:(NSString * _Nonnull)key {
    
    id result = @"";
    NSArray *array = valueForDictionaryFile(@"keyFliter")[key];
    for(NSString *str in array) {
        result = [self objectForKey:str];
        if(result) {break;}
    }
    return result;
}

@end
