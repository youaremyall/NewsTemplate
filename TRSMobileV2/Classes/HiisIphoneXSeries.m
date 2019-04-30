//
//  HiisIphoneXSeries.m
//  XYHiRepairs
//
//  Created by krystal on 2019/4/12.
//  Copyright © 2019 Kingnet. All rights reserved.
//

#import "HiisIphoneXSeries.h"

@implementation HiisIphoneXSeries


+ (BOOL)isIPhoneXSeries{
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

@end
