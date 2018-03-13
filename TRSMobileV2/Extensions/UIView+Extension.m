//
//  UIView+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/25.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIView+Extension.h"

#pragma mark -
@implementation UIView (CALayer)

- (void)setCornerWithRadius:(CGFloat)radius {

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius  = radius;
}

- (void)setBorderWithColor:(UIColor * _Nonnull)color borderWidth:(CGFloat)borderWidth {

    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)setShadowWithColor:(UIColor * _Nonnull)color shadowOpacity:(CGFloat)shadowOpacity shadowOffset:(CGSize)shadowOffset {

    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowOffset  = shadowOffset;
}

- (void)setGradientWithColors:(NSArray * _Nonnull)gradientColors gradientRect:(CGRect )gradientRect {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientRect;
    gradient.colors = gradientColors;
    [self.layer insertSublayer:gradient atIndex:0];
}

@end


#pragma mark -
@implementation UIView  (CGRect)

- (CGFloat)x {return  self.frame.origin.x;}

- (CGFloat)y {return  self.frame.origin.y;}

- (CGFloat)width {return  self.frame.size.width;}

- (CGFloat)height {return  self.frame.size.height;}

- (void)setX:(CGFloat)x {
    
    self.frame = CGRectMake(x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setY:(CGFloat)y {

    self.frame = CGRectMake(self.frame.origin.x,
                            y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setWidth:(CGFloat)width {

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            width,
                            self.frame.size.height);
}

- (void)setHeight:(CGFloat)height {

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            height);
}

- (void)setOrigin:(CGPoint)point {

    self.frame = CGRectMake(point.x,
                            point.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setSize:(CGSize)size {

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            size.width,
                            size.height);
}

@end


#pragma mark -
@implementation UIView (UIGestureRecognizer)

- (void)addTapGesture:(id _Nonnull)target selector:(SEL _Nonnull)selector {

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:recognizer];
}

- (void)addPanGesture:(id _Nonnull)target selector:(SEL _Nonnull)selector {

    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:target action:selector];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:recognizer];
}

- (void)addLongPressGesture:(id _Nonnull)target selector:(SEL _Nonnull)selector {

    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:selector];
    recognizer.minimumPressDuration = 0.3;
    [self addGestureRecognizer:recognizer];
}

@end


#pragma mark -
@implementation UIView (UIView_CAAnimation)

- (void)animationHeartBeat {

    [UIView animateWithDuration:0.1
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.01f, 1.01f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              self.transform = CGAffineTransformMakeScale(0.99f, 0.99f);
                                          }
                                          completion:^(BOOL finished) {
                                              self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                          }];
                     }];
}

- (void)animationCurveEaseOut {

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)animationShake:(BOOL)enable {

    if(enable) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:-0.05];
        animation.toValue = [NSNumber numberWithFloat:+0.05];
        animation.duration = 0.1;
        animation.autoreverses = YES; //是否重复
        animation.repeatCount = MAXFLOAT;
        [self.layer addAnimation:animation forKey:@"shake"];
    }
    else {
        [self.layer removeAnimationForKey:@"shake"];
    }
}

- (CABasicAnimation * _Nonnull)animationRotate:(CGFloat)value {

    CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
    rotate.toValue = [NSNumber numberWithFloat:M_PI*2];
    rotate.repeatCount = MAXFLOAT;
    rotate.duration = 10; //动画整体时间为0.05s * 60 = 3s
    rotate.cumulative = YES;
    rotate.delegate = (id<CAAnimationDelegate>)self;
    [self.layer addAnimation:rotate forKey:@"rotateAnimation"];
    return rotate;
}

@end

#pragma mark -
@implementation UIView  (UIResponder)

- (UIView * _Nonnull)findFirstResponder {
    
    if (self.isFirstResponder) return self;
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        if (firstResponder != nil) return firstResponder;
    }
    return nil;
}

@end

#pragma mark -
@implementation UIWindow (Extension)

+ (void)enableNightMode:(BOOL)enable {

    UIView *overlay = [[UIApplication sharedApplication].keyWindow viewWithTag:0x10102];
    if(enable) {
        if(overlay == nil) {
            overlay = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
            overlay.tag = 0x10102;
            overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            overlay.userInteractionEnabled = NO;
            [[UIApplication sharedApplication].keyWindow addSubview:overlay];
        }
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:overlay];
    }
    else {
        if(overlay != nil) {
            [overlay removeFromSuperview]; overlay = nil;
        }
    }
}

@end
