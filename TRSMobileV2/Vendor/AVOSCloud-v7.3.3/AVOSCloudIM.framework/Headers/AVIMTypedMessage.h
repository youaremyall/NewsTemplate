//
//  AVIMTypedMessage.h
//  AVOSCloudIM
//
//  Created by Qihe Bian on 1/8/15.
//  Copyright (c) 2014 LeanCloud Inc. All rights reserved.
//

#import "AVIMMessage.h"

@class AVFile;
@class AVGeoPoint;

NS_ASSUME_NONNULL_BEGIN

@protocol AVIMTypedMessageSubclassing <NSObject>
@required
/*!
 子类实现此方法用于返回该类对应的消息类型
 @return 消息类型
 */
+ (AVIMMessageMediaType)classMediaType;
@end

/**
 *  Base class for rich media message.
 */
@interface AVIMTypedMessage : AVIMMessage

@property (nonatomic,   copy, nullable)           NSString             *text;       // 消息文本
@property (nonatomic, strong, nullable)           NSDictionary         *attributes; // 自定义属性
@property (nonatomic, strong, readonly, nullable) AVFile               *file;       // 附件
@property (nonatomic, strong, readonly, nullable) AVGeoPoint           *location;   // 位置

/**
 * Add custom property for message.
 *
 * @param object The property value.
 * @param key    The property name.
 */
- (void)setObject:(nullable id)object forKey:(NSString *)key;

/**
 Get a user-defiend property for a key.

 @param key The key of property that you want to get.
 @return The value for key.
 */
- (nullable id)objectForKey:(NSString *)key;

/**
 *  子类调用此方法进行注册，一般可在子类的 [+(void)load] 方法里面调用
 */
+ (void)registerSubclass;

/*!
 使用本地文件，创建消息。
 @param text － 消息文本。
 @param attachedFilePath － 本地文件路径。
 @param attributes － 用户附加属性。
 */
+ (instancetype)messageWithText:(nullable NSString *)text
               attachedFilePath:(NSString *)attachedFilePath
                     attributes:(nullable NSDictionary *)attributes;

/*!
 使用 AVFile，创建消息。
 @param text － 消息文本。
 @param file － AVFile 对象。
 @param attributes － 用户附加属性。
 */
+ (instancetype)messageWithText:(nullable NSString *)text
                           file:(AVFile *)file
                     attributes:(nullable NSDictionary *)attributes;

@end

NS_ASSUME_NONNULL_END
