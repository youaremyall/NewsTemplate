//
//  NSBundle+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/30.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSBundle (Extension)

/**
 * @brief 简洁从NSNib文件加载view
 * @param name : 资源文件名
 */
+ (id _Nullable)instanceWithBundleNib:(NSString * _Nonnull)name;

/**
 * @brief 从主程序资源文件Info.plist文件根据键值获取信息
 * @param key :
 */
+ (id _Nullable)objectForCFBundleKey:(NSString * _Nonnull)key;

@end
