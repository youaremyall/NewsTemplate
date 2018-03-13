//
//  TRSTA+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 2017/2/22.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import "TRSTA+Provider.h"
#import "NSDictionary+Extension.h"
#import "UIDevice+Extension.h"

@implementation TRSRequest (TRSTA_Provider)

+ (void)load {

    //填写获取的AppKey、AppID以及发布渠道
    [TRSRequest setAppKey:valueForDictionaryFile(@"Vendor")[@"TRSTAAppKey"]
                 setAppID:valueForDictionaryFile(@"Vendor")[@"TRSTAAppId"]
               andChannel:@"App Store"];
    
    //填写统计URL渠道，以及用户登录账号
    [TRSRequest statisticsURL:@"http://ta.trs.cn/a/ta"
                    loginUser:([AVUser currentUser] ? [AVUser currentUser].username : @"")
                  andDeviceID:getDeviceId()];
}

@end
