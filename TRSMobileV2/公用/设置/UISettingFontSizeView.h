//
//  UISettingFontSizeView.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/22.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISettingFontSizeView : UIView

/**
 * @brief 显示调整字体大小
 * @param parent : 需要显示的view
 * @param changeBlock : 字体大小更改回调
 * @param dismissBlock: 界面消失回调
 * @return 无
 */
+ (void)showInView:(UIView *)parent changeBlock:(void(^)(NSInteger fontSize))changeBlock dismissBlock:(void(^)(void))dismissBlock;

@end
