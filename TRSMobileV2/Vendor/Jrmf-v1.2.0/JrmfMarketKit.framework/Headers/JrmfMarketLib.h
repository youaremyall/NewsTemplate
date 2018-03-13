//
//  JrmfMarketLib.h
//  MyFramework
//
//  Created by 一路财富 on 16/4/27.
//  Copyright © 2016年 JYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JrmfMarketLib : NSObject

/**
 *  根据红包URL打开红包
 *
 *  @param url 红包链接
 */
- (void)doActionPresentOpenRedPacketViewControllerWithUrl:(NSString *)url;

/**
 打开我的钱包

 @param url     钱包连接
 @param token   token值
 */
- (void)doActionPresentWalletViewControllerWithUrl:(NSString *)url WithToken:(NSString *)token;

/**
 *  版本号
 *
 *  @return 获取当前版本
 */
+ (NSString *)getCurrentVersion;

    
@end
