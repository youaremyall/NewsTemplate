//
//  UIFont+Provider.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *_Nonnull const didUIFontChangeNotification;

@interface  UIFontProvider : NSObject

/**
 * @brief 单例实例
 */
+ (instancetype _Nonnull) sharedInstance;

/**
 * @brief 设置字体库文件路径
 */
- (void) setFontPath:(NSString * _Nonnull)fontPath;

/**
 * @brief 根据字体文件路径获取字体
 * 对于TTF、OTF的字体都有效，但是对于TTC字体，只取出了一种字体。
 */
- (UIFont * _Nullable)fontWithPath:(NSString* _Nonnull)path size:(CGFloat)size;

/**
 * @brief 还原字体为默认
 */
- (void) resetFont;

@end
