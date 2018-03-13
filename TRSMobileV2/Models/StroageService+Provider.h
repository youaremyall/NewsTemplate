//
//  StroageService+Provider.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/11.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagicalRecord+Provider.h"

typedef NS_ENUM(NSInteger, serviceType){
    serviceTypeDefault = 0x00,  //默认请求数据
    serviceTypeFavorite,        //用户收藏
    serviceTypeHistory,         //浏览记录
    serviceTypeUser,            //用户有关
    serviceTypeAll              //所有数据
};

@interface MagicalRecordCache : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

@interface MagicalRecordCache (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) id value;
@property (nonatomic) int16_t type;
@property (nonatomic) NSTimeInterval timestamp;

@end

@interface StroageService : NSObject

/**
 * @brief 存储数据到数据库中
 * @param value : 通常的JSON数据类型为NSArray或NSDictionary
 * @param key   : 访问键字段
 * @param serviceType  : 数据类型 (这里不应该传入serviceTypeAll)
 */
+ (BOOL)setValue:(id _Nonnull)value forKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType;

/**
 * @brief 根据存储的访问键key，返回通常的JSON数据类型为NSArray或NSDictionary
 * @param key : 访问键字段
 * @param serviceType  : 数据类型
 * @return 返回为 数据类型为NSArray或NSDictionary
 */
+ (id _Nullable)valueForKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType;

/**
 * @brief 判断某个键字段是否已经在数据库中存储过
 * @param key : 访问键字段
 * @param serviceType  : 数据类型
 */
+ (BOOL)hasValueForKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType;

/**
 * @brief 根据键字段，从数据库中删除记录
 * @param key : 访问键字段
 * @param serviceType  : 数据类型
 */
+ (BOOL)removeValueForKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType;

/**
 * @brief 返回指定数据类型的记录总数
 * @param serviceType  : 数据类型
 * @return 返回为 NSInteger 总数
 */
+ (NSUInteger)totalValuesForType:(serviceType)serviceType;

/**
 * @brief 根据数据类型，返回通常的JSON数据类型为NSArray或NSDictionary
 * @param serviceType  : 数据类型
 * @param offset  : 查询偏移量
 * @param limit  : 查询每页条数，默认为20;
 * @return 返回为 MagicalRecordCache对象的数组
 */
+ (id _Nullable)valuesForType:(serviceType)serviceType offset:(NSUInteger)offset limit:(NSUInteger)limit;

/**
 * @brief 根据数据类型，从数据库中删除同类型的记录
 * @param serviceType  : 数据类型
 */
+ (BOOL)removeValuesForType:(serviceType)serviceType;

/**
 * @brief 根据传入的对象，从数据库中批量删除记录
 * @param array : MagicalRecordCache对象的数组
 * @return 操作成功结果
 */
+ (BOOL)removeValuesForArray:(NSArray * _Nonnull)array;

@end
