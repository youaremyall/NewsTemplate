//
//  JPush+Provider.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/8.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "JPUSHService.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
//在这里写针对iOS10的代码或者引用新的API
#import <UserNotifications/UserNotifications.h>
#endif

@interface JPUSHProvider : NSObject


@end
