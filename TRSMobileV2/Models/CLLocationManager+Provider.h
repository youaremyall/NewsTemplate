//
//  CLLocationManagerProvider.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/11.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocationManagerProvider : NSObject <CLLocationManagerDelegate>

/**
 * 定位管理器
 */
@property (strong, nonatomic) CLLocationManager *locationManager;

/**
 * 定位回调
 */
@property (strong, nonatomic) void (^locationBlock)(CLPlacemark *placemark, NSError *error);

/**
 * 类单例
 */
+ (instancetype)sharedInstance;

@end
