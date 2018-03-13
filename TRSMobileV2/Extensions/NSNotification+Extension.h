//
//  NSNotification+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/1.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief 添加通知监听
 */
void addNotificationObserver(id _Nonnull observer, SEL _Nonnull selector, NSString * _Nonnull name, id _Nullable object);

/**
 * @brief 发送通知
 */
void postNotificationName(NSString *_Nonnull name, id _Nullable object, NSDictionary * _Nullable userInfo);

/**
 * @brief 移除指定名称的通知监听
 */
void removeNotificationObserver(id _Nonnull observer, NSString *_Nonnull name, id _Nullable object);

/**
 * @brief 移除所有通知监听
 */
void removeNotifcationObserverAll(id _Nonnull observer);
