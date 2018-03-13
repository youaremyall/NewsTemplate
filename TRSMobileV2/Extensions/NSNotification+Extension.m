//
//  NSNotification+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/1.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSNotification+Extension.h"

void addNotificationObserver(id _Nonnull observer, SEL _Nonnull selector, NSString * _Nonnull name, id _Nullable object) {
    
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}

void postNotificationName(NSString *_Nonnull name, id _Nullable object, NSDictionary * _Nullable userInfo) {

    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

void removeNotificationObserver(id _Nonnull observer, NSString *_Nonnull name, id _Nullable object) {

    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
}

void removeNotifcationObserverAll(id _Nonnull observer) {
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}
