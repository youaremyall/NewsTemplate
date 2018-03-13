//
//  JPush+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/8.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPush+Provider.h"
#import "NSDictionary+Extension.h"

@implementation JPUSHProvider

#pragma mark -

+ (void)load {
    
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:YES];
}

+ (instancetype)sharedInstance {
    
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init {
    
    if(self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    // 必须的
    
    //注册推送通知服务，并清除通知栏中本应用的所有通知
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:(id<JPUSHRegisterDelegate>)[UIApplication sharedApplication].delegate];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }else {
        
        // categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeAlert|
                                                          UIUserNotificationTypeBadge|
                                                          UIUserNotificationTypeSound)
                                              categories:nil];
    }
    
    /**
     * 注册极光推送服务 (平台的配置信息从"Vendor.plist"文件读取)
     * @param launchingOption 启动参数.
     */
    [JPUSHService setupWithOption:notification.userInfo
                           appKey:valueForDictionaryFile(@"Vendor")[@"JPushAppKey"]
                          channel:valueForDictionaryFile(@"Vendor")[@"JPushChannel"]
                 apsForProduction:[valueForDictionaryFile(@"Vendor")[@"JPushAPSIsProduction"] boolValue] ];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [JPUSHService resetBadge]; //清除JPush服务器对badge值的设定.
}

@end
