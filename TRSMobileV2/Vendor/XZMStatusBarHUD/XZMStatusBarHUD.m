//
//  XZMStatusBarHUD.m
//  0731-XZMStatusBarHUD
//
//  Created by 谢忠敏 on 15/7/31.
//  Copyright (c) 2015年 谢忠敏. All rights reserved.
//

#import "XZMStatusBarHUD.h"

#define XZMScreenW [UIScreen mainScreen].bounds.size.width

static UIWindow *window_;
static NSTimer *timer_;

/** 消息显示\隐藏的动画时间 */
static CGFloat animaDelay_ = 0.5f;
static UIActivityIndicatorView *indicatorView_;
static CGFloat position_;
static UIButton *btn_;
static UIImageView *icon_;
static UILabel  *label_;

@implementation XZMStatusBarHUD

+ (instancetype)sharedInstance {

    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)showWindow
{
    window_.hidden = YES;
    window_ = [[UIWindow alloc] init];
    window_.frame = CGRectMake(0, position_-self.statusH, XZMScreenW, self.statusH);
    /** window的显示级别 */
    window_.windowLevel = self.windowLevel;
    window_.hidden = NO;
    
    /** 添加动画 */
    [UIView animateWithDuration:animaDelay_ animations:^{
        CGRect windowF = window_.frame;
        windowF.origin.y = position_;
        window_.frame = windowF;
    }];
}

- (void)showMessage:(NSString *)message image:(UIImage *)image position:(CGFloat)position animaDelay:(CGFloat)animaDelay configuration:(void (^)(void))configurationBlock
{
    position_ = position;
    if (animaDelay) animaDelay_ = animaDelay;
    
    /** 停止定时器 */
    [timer_ invalidate];
    
    /** 清空属性 */
    [self clearStatus];
    
    /** 执行配置数据 */
    if(configurationBlock) configurationBlock();
    
    /** 显示窗口 */
    [self showWindow];
    [window_ setBackgroundColor:self.statusColor];
    [self.formView addSubview:window_];
    /** 添加容器View */
    [window_ addSubview:self.statusbackgroundView];
    
    /** 添加按钮 */
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = _statusbackgroundView.bounds;
    [self.statusbackgroundView addSubview:btn];
    btn_ = btn;
    
    
    /** 提示图标 */
    CGFloat offset = (_statusH > 20.0) ? (20.0 - 8.0) : 0.0;
    UIImageView *imgview = [[UIImageView alloc] init];
    imgview.backgroundColor = [UIColor clearColor];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    imgview.layer.masksToBounds = YES;
    imgview.frame = CGRectMake(10, 0, 20.0, 20.0);
    imgview.center= CGPointMake(imgview.center.x, _statusbackgroundView.center.y + offset/2.0);
    imgview.image = image;
    [self.statusbackgroundView addSubview:imgview];
    icon_ = imgview;
    
    /** 文字标签 */
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = self.attributedText[NSFontAttributeName];
    label.textColor = self.attributedText[NSForegroundColorAttributeName];
    label.text = message;
    label.frame = CGRectMake(CGRectGetMaxX(icon_.frame) + 8.0, 0 + offset, XZMScreenW - CGRectGetMaxX(icon_.frame), _statusH - offset);
    [self.statusbackgroundView addSubview:label];
    label_ = label;
    
    /** 添加UIActivityIndicatorView */
    indicatorView_ = [[UIActivityIndicatorView alloc] init];
    [indicatorView_ startAnimating];
    [self.statusbackgroundView addSubview:indicatorView_];
    CGFloat indicatorViewW = indicatorView_.frame.size.width;
    CGSize maxSize = CGSizeMake(XZMScreenW, MAXFLOAT);
    CGFloat textW = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:self.attributedText context:nil].size.width;
    CGFloat indicatorCenterX = (XZMScreenW - textW) * 0.5 - indicatorViewW - 15;
    CGFloat indicatorCenterY = window_.frame.size.height * 0.5;
    indicatorView_.center = CGPointMake(indicatorCenterX, indicatorCenterY);
    indicatorView_.hidden = YES;
    
    /** 创建定时器 */
    timer_ = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hidden) userInfo:nil repeats:YES];
}

- (void)showMessage:(NSString *)message image:(UIImage *)image position:(CGFloat)position animaDelay:(CGFloat)animaDelay hidden:(BOOL)hidden configuration:(void(^)(void))configurationBlock {

    [self showMessage:message image:image position:position animaDelay:animaDelay configuration:configurationBlock];
    if(!hidden) {
        [timer_ invalidate];
        timer_ = nil;
    }
}

- (void)showSuccess:(NSString *)success position:(CGFloat)position animaDelay:(CGFloat)animaDelay configuration:(void (^)(void))configurationBlock
{
    [self showMessage:success image:[UIImage imageNamed:@"XZMStatusBarHUD.bundle/success"] position:position animaDelay:animaDelay configuration:configurationBlock];
}

- (void)showError:(NSString *)error position:(CGFloat)position animaDelay:(CGFloat)animaDelay configuration:(void (^)(void))configurationBlock
{
    [self showMessage:error image:[UIImage imageNamed:@"XZMStatusBarHUD.bundle/error"] position:position animaDelay:animaDelay configuration:configurationBlock];
}


- (void)showNormal:(NSString *)normal position:(CGFloat)position animaDelay:(CGFloat)animaDelay configuration:(void (^)(void))configurationBlock
{
    [self showMessage:normal image:nil position:position animaDelay:animaDelay configuration:configurationBlock];
}

- (void)showLoading:(NSString *)loading position:(CGFloat)position animaDelay:(CGFloat)animaDelay configuration:(void(^)(void))configurationBlock
{
    
    [self showMessage:loading image:nil position:position animaDelay:animaDelay configuration:configurationBlock];
    [timer_ invalidate];
    timer_ = nil;
    indicatorView_.hidden = NO;
}

- (void)hidden
{
    [UIView animateWithDuration:animaDelay_ animations:^{
        CGRect windowF = window_.frame;
        windowF.origin.y = position_ - self.statusH;
        window_.frame = windowF;
    } completion:^(BOOL finished) {
      
    }];
}

- (void)showSuccess:(NSString *)success position:(CGFloat)position
{
    [self showSuccess:success position:position animaDelay:0 configuration:nil];
}

- (void)showLoading:(NSString *)loading position:(CGFloat)position
{
    [self showLoading:loading position:position animaDelay:0 configuration:nil];
    indicatorView_.hidden = NO;
}

- (void)showError:(NSString *)error position:(CGFloat)position
{
    [self showError:error position:position animaDelay:0 configuration:nil];
}


- (void)showNormal:(NSString *)normal position:(CGFloat)position
{
    [self showNormal:normal position:position animaDelay:0 configuration:nil];
}

- (void)setHUDMessmage:(NSString *)message image:(UIImage *)image
{
    [label_ setText:message];
    [icon_ setImage:image];
}

- (CGFloat)statusAlpha
{
    if (_statusAlpha == 0 && _statusAlpha != 1.0) {
        
       _statusAlpha = 1.0;
    }
    return _statusAlpha;
}

- (UIColor *)statusColor
{
    if (_statusColor == nil) {
        
        _statusColor = [UIColor orangeColor];
    }
   return _statusColor;
}

- (CGFloat)statusH
{
    if (_statusH <= 0 && _statusH != 20) {
        _statusH = 20;
    }
    return _statusH;
    
}

- (NSMutableDictionary *)attributedText
{
    if (_attributedText == nil) {
        
        _attributedText = @{}.mutableCopy;
        
        _attributedText[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        
        _attributedText[NSForegroundColorAttributeName] = [UIColor whiteColor];
    }
    return _attributedText;
}

- (UIView *)statusbackgroundView
{
    if (_statusbackgroundView == nil) {
        _statusbackgroundView = [[UIView alloc] init];
    }
    _statusbackgroundView.frame = CGRectMake(0, 0, XZMScreenW, self.statusH);
    return _statusbackgroundView;
}

- (void)clearStatus
{
    [btn_ removeFromSuperview];
    [indicatorView_ removeFromSuperview];
    btn_ = nil;
    indicatorView_ = nil;
    
    _statusAlpha = 0;
    _statusbackgroundView = nil;
    _statusColor = nil;
    _statusH = 0;
    _attributedText = nil;
}

- (void)didButtonSelect:(id)sender
{
    if(_statusBarBlock) {_statusBarBlock();}
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
