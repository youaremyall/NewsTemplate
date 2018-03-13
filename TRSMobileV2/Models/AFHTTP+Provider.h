//
//  AFHTTP+Provider.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/16.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "XZMStatusBarHUD.h"

//全局公用静态的当前网络状态
extern AFNetworkReachabilityStatus statusAFNetworkReachability;

typedef NS_ENUM(NSInteger, compareType) {
    
    compareTypeNone = 0x00,     //不做比较
    compareTypeOverview,        //概览比较
    compareTypeDetail           //细览比较
};

typedef NS_ENUM(NSInteger, cachePolicy) {
    
    cachePolicyNone = 0x00,     //不做缓存
    cachePolicyYes              //缓存数据
};

typedef void (^progress)(float progress);
typedef void (^completion)(BOOL success, id _Nullable response, NSError * _Nullable error);

@interface AFHTTP : NSObject

/**
 * @brief 根据url地址请求数据
 * @param url : 请求url地址
 * @param completion : 回调函数
 * @return 无
 */
+ (void)request:(NSString * _Nonnull)url
     completion:(completion _Nullable)completion;

/**
 * @brief 根据url地址请求数据
 * @param url : 请求url地址
 * @param cachePolicy : 数据缓存策略
 * @param completion : 回调函数
 * @return 无
 */
+ (void)request:(NSString * _Nonnull)url
    cachePolicy:(cachePolicy)cachePolicy
     completion:(completion _Nullable)completion;

/**
 * @brief 根据url地址请求数据
 * @param url : 请求url地址
 * @param method : 数据方式，在如下常用的GET、POST中选择，默认为GET
 * @param parameters : 传入POST body的参数, 需为NSDictionary类型
 * @param progress : 进度回调
 * @param completion : 回调函数
 * @return 无
 */
+ (void)request:(NSString * _Nonnull)url
         method:(NSString * _Nonnull)method
     parameters:(NSDictionary * _Nullable)parameters
       progress:(progress _Nullable)progress
     completion:(completion _Nullable)completion;

/**
 * @brief 根据url地址请求数据
 * @param url : 请求url地址
 * @param method : 数据方式，在如下常用的GET、POST中选择，默认为GET
 * @param parameters : 传入POST body的参数, 需为NSDictionary类型
 * @param type : 对比类型
 * @param cachePolicy : 数据缓存策略
 * @param progress : 进度回调
 * @param completion : 回调函数
 * @return 无
 */
+ (void)request:(NSString * _Nonnull)url
         method:(NSString * _Nonnull)method
     parameters:(NSDictionary * _Nullable)parameters
    compareType:(compareType)compareType
    cachePolicy:(cachePolicy)cachePolicy
       progress:(progress _Nullable)progress
     completion:(completion _Nullable)completion;

#pragma mark - SOAP

/**
 * @brief 获取指定url地址返回的soap数据, 返回为NSDictionary类型的数据
 * @param url : 请求url地址
 * @param completion : 回调函数
 * @return 无
 */
+ (void)soapRequest:(NSString * _Nonnull)url
         completion:(completion _Nullable)completion;

/**
 * @brief 获取指定url地址返回的soap数据, 返回为NSDictionary类型的数据
 * @param url : 请求url地址
 * @param method : soap协议支持的api接口方法 (备注:soap协议都为POST请求)
 * @param parameters : 传入POST body的参数, 需为NSDictionary类型
 * @param completion : 回调函数
 * @return 无
 */
+ (void)soapRequest:(NSString * _Nonnull)url
             method:(NSString * _Nullable)method
         parameters:(NSDictionary * _Nullable)parameters
         completion:(completion _Nullable)completion;


#pragma mark - HTTP

/**
 * @brief 获取指定url地址返回的原始数据
 * @param url : 请求url地址
 * @param completion : 回调函数
 * @return 无
 */
+ (void)httpRequest:(NSString * _Nonnull)url
         completion:(completion _Nullable)completion;

/**
 * @brief 获取指定url地址返回的原始数据
 * @param url : 请求url地址
 * @param method : soap协议支持的api接口方法 (备注:soap协议都为POST请求)
 * @param parameters : 传入POST body的参数, 需为NSDictionary类型
 * @param completion : 回调函数
 * @return 无
 */
+ (void)httpRequest:(NSString * _Nonnull)url
             method:(NSString * _Nullable)method
         parameters:(NSDictionary * _Nullable)parameters
         completion:(completion _Nullable)completion;

#pragma mark - 上传下载

/**
 * @brief 上传文件到后台服务器
 * @param url : 请求url地址
 * @param files : 包含NSDictionary的文件数组，字段包含的数据字段(都不能为nil)如下
 *     {@"filename" : @"", @"name" : @"", @"filedata" : nil, @"mimeType" : @"image/jpeg"}
 *     默认图片的mimeType:image/jpeg, 视频mimeType : video/mp4
 * @param parameters : 传入POST body的参数, 需为NSDictionary类型
 * @param progress : 进度回调
 * @param completion : 回调函数
 * @return NSURLSessionDataTask 对象
 */
+ (NSURLSessionDataTask * _Nonnull)uploadFiles:(NSString * _Nonnull)url
                                         files:(NSArray * _Nonnull)files
                                    parameters:(NSDictionary * _Nonnull)parameters
                                      progress:(progress _Nullable)progress
                                    completion:(completion _Nullable)completion;

/**
 * @brief 从后台服务器下载文件
 * @param url : 请求url地址
 * @param parameters : 传入POST body的参数, 需为NSDictionary类型
 * @param targetPath : 文件存储目的路径
 * @param progress : 进度回调
 * @param completion : 回调函数
 * @return NSURLSessionDataTask 对象
 */
+ (NSURLSessionDataTask * _Nonnull)downloadFile:(NSString * _Nonnull)url
                                     targetPath:(NSString * _Nonnull)targetPath
                                     parameters:(NSDictionary * _Nullable)parameters
                                       progress:(progress _Nullable)progress
                                     completion:(completion _Nullable)completion;

@end
