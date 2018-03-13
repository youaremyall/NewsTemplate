//
//  UMAnalytics+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/8.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UMAnalytics+Provider.h"
#import "NSDictionary+Extension.h"

@implementation MobClick (UMAnalytics_Provider)

+ (void)load {

    //channelId为nil或@""时，默认会被当作@"App Store"渠道
    [UMConfigure initWithAppkey:valueForDictionaryFile(@"Vendor")[@"UMengAppKey"] channel:nil];
    
    // 统计组件配置
    [MobClick setScenarioType:E_UM_NORMAL];
}

@end
