//
//  CLLocationManagerProvider.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/11.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "CLLocationManager+Provider.h"

@implementation CLLocationManagerProvider

+ (instancetype)sharedInstance {
    
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init {
    
    if((self = [super init])) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
        
        if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization]; //获取访问隐私权限-定位服务授权
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {

    /*应用进入后台的调用顺序: applicationWillResignActive -> applicationDidEnterBackground */
    
    /* 停止定位服务 */
    NSLog(@"应用进入后台停止定位服务");
    [_locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {

    /*应用进入前台的调用顺序: applicationWillEnterForeground -> applicationDidBecomeActive */

    /* 开启定位服务 */
    NSLog(@"应用进入前台开启定位服务");
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagedelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"定位服务授权状态已改变 : %d", status);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locations.lastObject
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       
                       if(placemarks.count > 0) {
                           CLPlacemark *placemark = placemarks[0];
                           //获取城市
                           NSString *city = placemark.locality;
                           if(!city) {
                               //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                               city = placemark.administrativeArea;
                           }
                           NSLog(@"当前定位城市 : %@", city);
                           if(_locationBlock) {_locationBlock(placemark, error); }
                           
                       }
                       else if(error == nil && placemarks.count == 0) {
                           NSLog(@"未解析到当前定位城市");
                       }
                       else {
                           NSLog(@"地理位置方向解析失败");
                       }
                   }];
    
    NSLog(@"定位成功: %@", [locations.lastObject description]);
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"定位失败: %@", error.localizedDescription);
    [manager stopUpdatingLocation];
    if(_locationBlock) {_locationBlock(nil, error); }
}

@end
