//
//  NSUserDefaults+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/7.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSUserDefaults+Extension.h"


@implementation NSUserDefaults (Extension)

+ (NSString * _Nonnull)systemLanguage {
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    return [languages objectAtIndex:0];
}

+ (BOOL)setObjectForKey:(id _Nonnull)obj key:(NSString * _Nonnull)key {

    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setSettingValue:(id _Nonnull)value type:(SettingType)type {

    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"setting"] ];
    if(!setting) {
        setting = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    [setting setObject:value forKey:@(type).stringValue];
    [[NSUserDefaults standardUserDefaults] setObject:setting forKey:@"setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id _Nonnull)settingValueForType:(SettingType)type {

    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"setting"];
    if(setting && [setting objectForKey:@(type).stringValue ]) {
        
        return [setting objectForKey:@(type).stringValue ];
    }
    
    switch (type) {
        case SettingTypeFontFamily:
            return @"系统字体";
        case SettingTypeFontSize:
            return @(2);
        case SettingTypeAutoPlayVideo:
            return @(0);
        case SettingTypeOnlyWiFiLoadImages:
            return @(YES);
        case SettingTypePushReceive:
            return @(YES);
        case SettingTypeCommentNoUser:
            return @(NO);
        case SettingTypeNightMode:
            return @(NO);
        default:
            break;
    }
}

@end
