//
//  UIWebView+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/5/9.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Extension)

/**
 * @brief 禁用网页滚动超过边界时的拖拽阴影
 */
- (void)disableOutOfBoundaryShadow;

/**
 * @brief 设置网页内容属性
 */
- (void)setWebViewHtmlProperty;

/**
 * @brief 设置网页显示的字体大小
 */
- (void)setWebViewHtmlFont;

@end
