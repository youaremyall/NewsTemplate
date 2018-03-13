//
//  Bugly+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 2017/2/18.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import "Bugly+Provider.h"
#import "NSDictionary+Extension.h"

@implementation Bugly (Bugly_Provider)

+ (void) load {

    [Bugly startWithAppId:valueForDictionaryFile(@"Vendor")[@"BuglyAppId"] ];
}

@end
