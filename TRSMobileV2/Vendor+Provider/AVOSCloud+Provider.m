//
//  AVOSCloud+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "AVOSCloud+Provider.h"
#import "NSDictionary+Extension.h"

@implementation AVOSCloud (AVOSCloud_Provider)

+ (void)load {
    
    [self performSelectorOnMainThread:@selector(__init) withObject:nil waitUntilDone:NO];
}

+ (void)__init{
    
    [AVOSCloud setApplicationId:valueForDictionaryFile(@"Vendor")[@"AVOSCloudAppId"]
                      clientKey:valueForDictionaryFile(@"Vendor")[@"AVOSCloudAppKey"] ];
}

+ (NSString *)errorString:(NSInteger)errorCode {

    NSString *key = [NSString stringWithFormat:@"%ld", errorCode];
    NSString *error = valueForDictionaryFile(@"AVOSCloudError")[key];
    if(!error) {
        error = @"未知错误";
    }
    return error;
}

@end
