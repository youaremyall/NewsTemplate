//
//  UISettingFontSizeView.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/22.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UISettingFontSizeView.h"
#import "UIColor+Extension.h"
#import "UIView+Extension.h"
#import "NSUserDefaults+Extension.h"

@interface UISettingFontSizeView ()

@property (strong, nonatomic) UIView   *viewFont; //字体大小更改图层
@property (assign, nonatomic) BOOL     isShowLine;
@property (copy, nonatomic) void(^changeBlock)(NSInteger fontSize);
@property (copy, nonatomic) void(^dismissBlock)(void);

@end

@implementation UISettingFontSizeView

/**
 * @brief 显示调整字体大小
 * @param parent : 需要显示的view
 * @param changeBlock : 字体大小更改回调
 * @param dismissBlock: 界面消失回调
 * @return 无
 */
+ (void)showInView:(UIView *)parent changeBlock:(void(^)(NSInteger fontSize))changeBlock dismissBlock:(void(^)(void))dismissBlock {

    UISettingFontSizeView *instance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    instance.changeBlock = changeBlock;
    instance.dismissBlock = dismissBlock;
    [parent addSubview:instance];
    
    instance.viewFont.y = CGRectGetHeight(instance.frame);
    [UIView animateWithDuration:0.3f
                     animations:^{
                         instance.viewFont.y = CGRectGetHeight(instance.frame) - CGRectGetHeight(instance.viewFont.frame);
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark -
- (instancetype)initWithFrame:(CGRect)frame {

    if(self = [super initWithFrame:frame]) {
        
        self.isShowLine = YES;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *_viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _viewBG.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        _viewBG.userInteractionEnabled = YES;
        [_viewBG addTapGesture:self selector:@selector(dismiss)];
        [self addSubview:_viewBG];
        
        _viewFont = [UIButton buttonWithType:UIButtonTypeCustom];
        _viewFont.frame = CGRectMake(0, CGRectGetHeight(frame) - 200.0, CGRectGetWidth(frame), 200.0);
        _viewFont.backgroundColor = [UIColor whiteColor];
        [self addSubview:_viewFont];
        
        /*横线的画法*/
        UIView *_line = [[UIView alloc] initWithFrame:CGRectMake(30, 90 + 31.0/2.0, CGRectGetWidth(frame) - 60.0, 1.0)];
        _line.backgroundColor = [UIColor lightGrayColor];
        _line.hidden = !_isShowLine;
        [_viewFont addSubview:_line];
        /*横线的画法完成*/

        NSArray *arr = @[@"极小", @"小", @"中", @"大", @"极大"];
        CGFloat x = 20.0; CGFloat y = 40.0;
        CGFloat w = 40.0;
        CGFloat space = (CGRectGetWidth(frame) - 2*x - arr.count*w) / (arr.count - 1);
        for(NSInteger i = 0; i < arr.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 40.0, 21.0)];
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:15.0];
            label.text = arr[i];
            [_viewFont addSubview:label];
            
            /*竖线的画法*/
            CGFloat __x;
            if( i == 0) {__x = x + 10.0;}
            else if(i == arr.count -1) {__x = (x + w - 10.0 -1.0);}
            else {__x = label.center.x;}
            CGFloat __h = ((i == 0 || i == arr.count - 1) ? 10.0 : 5.0);
            UIView *__line = [[UIView alloc] initWithFrame:CGRectMake(__x, (CGRectGetMinY(_line.frame) - __h), 1.0, __h)];
            __line.backgroundColor = _line.backgroundColor;
            __line.hidden = !_isShowLine;
            [_viewFont addSubview:__line];
            /*竖线的画法完成*/
            
            x += (w + space);
        }
        
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;
        slider.maximumValue = (arr.count - 1);
        slider.value = [[NSUserDefaults settingValueForType:SettingTypeFontSize] integerValue];
        if(_isShowLine) {
            slider.minimumTrackTintColor = [UIColor clearColor];
            slider.maximumTrackTintColor = [UIColor clearColor];
        }
        else {
            slider.minimumTrackTintColor = [UIColor redColor];
            slider.maximumTrackTintColor = [UIColor colorWithRGB:0xeeeeee alpha:1.0];
        }
        slider.thumbTintColor = [UIColor redColor];
        slider.continuous = NO;
        [slider setOrigin:CGPointMake(20, 90.f)];
        [slider setWidth:CGRectGetWidth(frame) - 2*20.0];
        [slider addTapGesture:self selector:@selector(sliderTap:)];
        [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [_viewFont addSubview:slider];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        cancel.frame = CGRectMake(0, CGRectGetHeight(_viewFont.frame) - 48.0, CGRectGetWidth(_viewFont.frame), 48.0);
        cancel.backgroundColor = [UIColor clearColor];
        cancel.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [cancel setBorderWithColor:[UIColor colorWithRGB:0xeeeeee alpha:1.0] borderWidth:1.0];
        [_viewFont addSubview:cancel];
    }
    return self;
}

- (void)sliderTap:(UITapGestureRecognizer *)recognizer {

    UISlider *slider = (UISlider *)recognizer.view;
    CGFloat value = (slider.maximumValue - slider.minimumValue) * ([recognizer locationInView:slider].x / CGRectGetWidth(recognizer.view.frame));
    
    [slider setValue:nearbyintf(value) animated:YES];
    [NSUserDefaults setSettingValue:@(slider.value) type:SettingTypeFontSize];
    if(_changeBlock) {_changeBlock(slider.value);}
}

- (void)valueChanged:(UISlider *)slider {

    [slider setValue:nearbyintf(slider.value) animated:YES];
    [NSUserDefaults setSettingValue:@(slider.value) type:SettingTypeFontSize];
    if(_changeBlock) {_changeBlock(slider.value);}
}

- (void)dismiss {

    [UIView animateWithDuration:0.3f
                     animations:^{
                         _viewFont.y = CGRectGetHeight(self.frame);
                     }
                     completion:^(BOOL finished) {
                         if(_dismissBlock) {_dismissBlock();}
                         [self removeFromSuperview];
                     }];
}

@end
