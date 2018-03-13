//
//  UIWebView+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/9.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIWebView+Extension.h"
#import "NSUserDefaults+Extension.h"

@implementation UIWebView (Extension)

- (void)disableOutOfBoundaryShadow {
    
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    for (UIView *view in [self subviews]){
        if ([view isKindOfClass:[UIScrollView class]]){
            for (UIView *obj in view.subviews){
                
                // 上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                if ([obj isKindOfClass:[UIImageView class]]){
                    obj.hidden = YES;
                    break;
                }
            }
        }
    }
}

- (void)setWebViewHtmlProperty {
    
    //移除头部
    NSString *header = @"document.getElementsByName(\"header\")[0].remove()";
    [self stringByEvaluatingJavaScriptFromString:header];
    
    //移除尾部
    NSString *footer = @"document.getElementsByName(\"footer\")[0].remove()";
    [self stringByEvaluatingJavaScriptFromString:footer];
    
    //修改viewport
    NSString *viewport = @"document.getElementsByName(\"viewport\")[0].content = \"width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"";
    [self stringByEvaluatingJavaScriptFromString:viewport];
}

- (void)setWebViewHtmlFont {
    
    NSInteger fontSize = [[NSUserDefaults settingValueForType:SettingTypeFontSize] integerValue];
    
    CGFloat scale = [@[@(0.5), @(0.75), @(1.0), @(1.25), @(1.5)][fontSize] floatValue];
    NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%f%%'", (scale * 100) ];
    [self stringByEvaluatingJavaScriptFromString:str];
}

@end
