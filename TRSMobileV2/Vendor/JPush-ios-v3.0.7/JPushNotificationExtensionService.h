/*
 *	| |    | |  \ \  / /  | |    | |   / _______|
 *	| |____| |   \ \/ /   | |____| |  / /
 *	| |____| |    \  /    | |____| |  | |   _____
 * 	| |    | |    /  \    | |    | |  | |  |____ |
 *  | |    | |   / /\ \   | |    | |  \ \______| |
 *  | |    | |  /_/  \_\  | |    | |   \_________|
 *
 * Copyright (c) 2017 Shenzhen HXHG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#define JPUSH_EXTENSION_VERSION_NUMBER 1.0.0

@class UNNotificationRequest;

@interface JPushNotificationExtensionService : NSObject

+ (void)jpushSetAppkey:(NSString *)appkey;

+ (void)jpushReceiveNotificationRequest:(UNNotificationRequest *)request with:(void (^)(void))completion;


@end
