//
//  StroageService+Provider.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/11.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "StroageService+Provider.h"

@implementation MagicalRecordCache

// Insert code here to add functionality to your managed object subclass

@end

@implementation MagicalRecordCache (CoreDataProperties)

@dynamic key;
@dynamic value;
@dynamic type;
@dynamic timestamp;

@end

@implementation StroageService

+ (BOOL)setValue:(id _Nonnull)value forKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType {

    //处理编码转换
    key = [key stringByRemovingPercentEncoding];
    
    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    //查找记录在数据库中是否存在
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key = %@ && type = %d)", key, serviceType];
    MagicalRecordCache *obj = [MagicalRecordCache MR_findFirstWithPredicate:predicate inContext:context];

    if(obj != nil) { //查找到记录，更新数据
        obj.value = value;
        obj.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    else { //未查找到记录，创新新记录并设置数据
        obj = [MagicalRecordCache MR_createEntity];
        obj.key = key;
        obj.value = value;
        obj.type = serviceType;
        obj.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    
    //写入到数据库保存
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
    }];
    
    return YES;
}

+ (id _Nullable)valueForKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType {

    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    //查找记录在数据库中是否存在
    NSPredicate *predicate = nil;
    if(serviceType == serviceTypeAll) {
        predicate = [NSPredicate predicateWithFormat:@"(key = %@)", key];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(key = %@ && type = %d)", key, serviceType];
    }
    
    return [MagicalRecordCache MR_findFirstWithPredicate:predicate sortedBy:@"timestamp" ascending:NO inContext:context].value;
}

+ (BOOL)hasValueForKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType {

    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    //设置过滤条件
    NSPredicate *predicate = nil;
    if(serviceType == serviceTypeAll) {
        predicate = [NSPredicate predicateWithFormat:@"(key = %@)", key];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(key = %@ && type = %d)", key, serviceType];
    }
    
    return ([MagicalRecordCache MR_findFirstWithPredicate:predicate inContext:context ] != nil);
}

+ (BOOL)removeValueForKey:(NSString * _Nonnull)key serviceType:(serviceType)serviceType {

    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    //查找记录在数据库中是否存在
    NSPredicate *predicate;
    BOOL result = NO;
    if(serviceType == serviceTypeAll) {
        predicate = [NSPredicate predicateWithFormat:@"(key = %@)", key];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(key = %@ && type = %d)", key, serviceType];
    }

    MagicalRecordCache *obj = [MagicalRecordCache MR_findFirstWithPredicate:predicate];
    if(obj != nil) { //查找到记录，更新数据
        result = [obj MR_deleteEntity];
    }
    //写入到数据库保存
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
    }];
    
    return result;
}

+ (NSUInteger)totalValuesForType:(serviceType)serviceType {

    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    //设置过滤条件
    if(serviceType == serviceTypeAll) {
        return [MagicalRecordCache MR_countOfEntitiesWithContext:context];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type = %d)", serviceType];
        return [MagicalRecordCache MR_countOfEntitiesWithPredicate:predicate inContext:context];
    }
}

+ (id _Nullable)valuesForType:(serviceType)serviceType offset:(NSUInteger)offset limit:(NSUInteger)limit {
    
    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    //获取查询条件
    NSPredicate *predicate =  ((serviceType == serviceTypeAll) ? nil : [NSPredicate predicateWithFormat:@"(type = %d)", serviceType]);
    NSFetchRequest *request = [MagicalRecordCache MR_requestAllSortedBy:@"timestamp" ascending:NO withPredicate:predicate];
    request.fetchOffset = offset;
    request.fetchLimit = limit;
    
    return [MagicalRecordCache MR_executeFetchRequest:request inContext:context];
}

+ (BOOL)removeValuesForType:(serviceType)serviceType {

    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type = %d )", serviceType];
    BOOL result = [MagicalRecordCache MR_deleteAllMatchingPredicate:predicate];
    
    //写入到数据库保存
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
    }];
    
    return result;
}

+ (BOOL)removeValuesForArray:(NSArray * _Nonnull)array {

    //查找上下文
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    //查找记录在数据库中是否存在
    BOOL result = NO;
    for(MagicalRecordCache *obj in array) { //删除记录
        result = [obj MR_deleteEntity];
    }
    
    //写入到数据库保存
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
    }];
    
    return result;
}

@end
