//
//  UIFont+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/18.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Extension)

/**
 * @brief 改变行间距
 * @param label : 文本控件
 * @param space : 行间距高度
 * @return 无
 */
+ (void)changeLineSpaceForLabel:(UILabel * _Nonnull)label WithSpace:(float)space;

/**
 * @brief 改变字间距
 * @param label : 文本控件
 * @param space : 子间距宽度
 * @return 无
 */
+ (void)changeWordSpaceForLabel:(UILabel * _Nonnull)label WithSpace:(float)space;

/**
 * @brief 改变行间距和字间距
 * @param label : 文本控件
 * @param lineSpace : 行间距高度
 * @param wordSpace : 子间距宽度
 * @return 无
 */
+ (void)changeSpaceForLabel:(UILabel * _Nonnull)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

/**
 * @brief 增加字体改变监听
 */
- (void)addDidFontChangeObserver;

@end


@interface UIButton (Extension)

/**
 * @brief 增加字体改变监听
 */
- (void)addDidFontChangeObserver;

@end
