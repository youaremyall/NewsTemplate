//
//  JrmfRedPacket.h
//  TRSMobileV2
//
//  Created by  TRS on 2017/1/19.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JrmfMarketKit/JrmfMarketLib.h>
#import "JrmfDefine.h"
#import "GTMBase64.h"

typedef void (^completionBlock)(BOOL success, NSDictionary* _Nullable envelope, NSError* _Nullable error);

@interface JrmfRedPacket : NSObject

/**
 * @brief 获取用户令牌
 * @param custUid  : 用户 Id，最大长度 64 字节。是用户在 App 中的唯一标识码，必须保证在同一个 App 内不重复，重复的用户 Id 将被当作是同一用户。
 * @param nickName : 用户昵称，最大长度 128 字节（非必填）
 * @param avatar   : 用户头像 URI，最大长度 1024 字节 （非必填, Base64编码）
 * @param completion: 回调
 */
+ (void)getWebToken:(NSString* _Nonnull)custUid nickName:(NSString* _Nullable)nickName avatar:(NSString* _Nullable)avatar completion:(completionBlock _Nullable)completion;

/**
 * @brief 发送唯一红包
 * @param redPacket : 红包埋点类型
 * @param webToken  : 用户令牌 （非必填）
 * @param completion: 回调
 */
+ (void)getOperateRedEnvelope:(NSString* _Nonnull )redPacket webToken:(NSString* _Nullable)webToken completion:(completionBlock _Nullable)completion;

/**
 * @brief 发送普惠红包
 * @param redPacket : 红包埋点类型
 * @param completion: 回调
 */
+ (void)getCommonRedEnvelope:(NSString* _Nonnull)redPacket webToken:(NSString* _Nullable)webToken completion:(completionBlock _Nullable)completioncompletion;

/**
 * @brief 发送卡券红包
 * @param redPacket : 红包埋点类型
 * @param webToken  : 用户令牌 （非必填）
 * @param completion: 回调
 */
+ (void)getCardCoupon:(NSString* _Nonnull )redPacket webToken:(NSString* _Nullable)webToken completion:(completionBlock _Nullable)completion;

@end
