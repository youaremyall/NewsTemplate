//
//  NSDate+Extensions.m
//  TRSMobile
//
//  Created by  TRS on 14/12/11.
//  Copyright (c) 2014年 TRS. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extensions)

+ (NSInteger)getYear:(NSDate * _Nonnull)date {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitYear fromDate:date];
    
    return components.year;
}

+ (NSInteger)getMonth:(NSDate * _Nonnull)date {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitMonth fromDate:date];
    
    return components.month;
}

+ (NSInteger)getDay:(NSDate * _Nonnull)date {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitDay fromDate:date];
    
    return components.day;
}

+ (NSInteger)getHour:(NSDate * _Nonnull)date {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitHour fromDate:date];
    
    return components.hour;
}

+ (NSInteger)getMinute:(NSDate * _Nonnull)date {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitMinute fromDate:date];
    
    return components.minute;
}

+ (NSInteger)getSecond:(NSDate * _Nonnull)date {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:NSCalendarUnitSecond fromDate:date];
    
    return components.second;
}

+ (NSDate * _Nonnull)dateByYear:(NSInteger)year
                         month:(NSInteger)month
                          date:(NSInteger)date
                          hour:(NSInteger)hour
                        minute:(NSInteger)minute
                        second:(NSInteger)second {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *componets = [[NSDateComponents alloc] init];
    componets.year = year;
    componets.month = month;
    componets.day = date;
    componets.hour = hour;
    componets.minute = minute;
    componets.second = second;
    
    return [calender dateFromComponents:componets];
}

+ (NSDate * _Nonnull)dateByDateString:(NSString * _Nonnull)dateString format:(NSString * _Nonnull)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"] ];
    [formatter setDateFormat:format];
    
    return [formatter dateFromString:dateString];
}

+ (NSDate * _Nonnull)dateByDateString:(NSString * _Nonnull)dateString format:(NSString * _Nonnull)format locale:(NSLocale * _Nonnull)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:locale];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"] ];
    [formatter setDateFormat:format];
    
    return [formatter dateFromString:dateString];
}

+ (NSString * _Nonnull)dateStringByDate:(NSDate * _Nonnull)date format:(NSString * _Nonnull)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"] ];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

+ (NSString * _Nonnull)dateStringByTimestamp:(double)timestamp format:(NSString * _Nonnull)format {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"] ];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

@end
