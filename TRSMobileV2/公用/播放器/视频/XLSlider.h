//
//  XLSlider.h
//  XLSlider
//
//  Created by Shelin on 16/3/18.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Extension.h"
#import "TRSMobile.h"

@class XLSlider;
@interface XLSlider : UIView

@property (nonatomic, assign) CGFloat value;        /* From 0 to 1 */
@property (nonatomic, assign) CGFloat middleValue;  /* From 0 to 1 */

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat sliderDiameter;
@property (nonatomic, strong) UIColor *sliderColor;
@property (nonatomic, strong) UIColor *maxColor;
@property (nonatomic, strong) UIColor *middleColor;
@property (nonatomic, strong) UIColor *minColor;

@property (nonatomic, copy) void (^valueChangeBlock)(XLSlider *slider);
@property (nonatomic, copy) void (^finishChangeBlock)(XLSlider *slider);
@property (nonatomic, strong) void (^draggingSliderBlock)(XLSlider *slider);


@end
