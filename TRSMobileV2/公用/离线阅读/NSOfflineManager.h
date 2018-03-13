//
//  NSOfflineManager.h
//  TRSMobile
//
//  Created by TRS on 14-5-29.
//  Copyright (c) 2014年 TRS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UINewsSubscribleItem.h"

@interface NSOfflineManager : NSObject

/**
 * @brief 离线阅读进度回调
 * @return 无
 */
@property (copy, nonatomic) void (^ _Nullable callback)(NSString * _Nonnull channelName, float percent, BOOL finish);

/**
 * @brief 取消标识
 * @return 无
 */
@property (assign, nonatomic) BOOL cancelDownload;

/**
 * @brief 离线下载管理
 * @return 无
 */
- (void)offlineManagerDownloading:(BOOL)enable;

@end
