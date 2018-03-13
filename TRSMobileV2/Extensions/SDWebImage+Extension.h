//
//  SDWebImage+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/15.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (Extension)

/**
 *  @brief 异步图片加载
 *  @param url             图片请求地址http://开头或本地文件file://开头
 *  @param placeholder     默认图片
 *  @param completionBlock 加载完成回调函数
 */
- (void)setUIImageWithURL:(NSString * _Nonnull)url
         placeholderImage:(UIImage * _Nullable)placeholder
                completed:(SDExternalCompletionBlock _Nullable)completionBlock;


/**
 *  @brief 异步图片加载
 *  @param url             图片请求地址http://开头或本地文件file://开头
 *  @param placeholder     默认图片
 *  @param progressBlock   加载进度回调函数
 *  @param completionBlock 加载完成回调函数
 */
- (void)setUIImageWithURL:(NSString * _Nonnull)url
         placeholderImage:(UIImage * _Nullable)placeholder
                 progress:(SDWebImageDownloaderProgressBlock _Nullable)progressBlock
                completed:(SDExternalCompletionBlock _Nullable)completionBlock;


@end
