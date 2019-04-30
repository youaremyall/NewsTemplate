//
//  SYLineProgressView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/11/15.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "SYLineProgressView.h"

static CGFloat const originXY = 1.0;

@interface SYLineProgressView ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation SYLineProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineView.frame = self.bounds;
        self.imageView.frame = CGRectMake(self.bounds.size.width - 20,0 , 10, self.bounds.size.height);
        
        [self bringSubviewToFront:self.progressView];
    }
    return self;
}

#pragma mark - getter

- (UIView *)lineView
{
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        [self addSubview:_lineView];
        _lineView.layer.borderColor = self.lineColor.CGColor;
        _lineView.layer.borderWidth = self.lineWidth;
        _lineView.layer.masksToBounds = YES;
    }
    return _lineView;
}

- (UIImageView*)imageView
{
    if(!_imageView)
    {
        _imageView=[[UIImageView alloc]init];
        [self addSubview:_imageView];
        _imageView.backgroundColor = [UIColor redColor];
    }
    return _imageView;
}


- (UIView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        [self addSubview:_progressView];
        _progressView.layer.masksToBounds = YES;
        _progressView.backgroundColor = self.progressColor;
    }
    return _progressView;
}

#pragma mark - setter

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (_progress < 0.0) {
        _progress = 0.0;
    }
    if (_progress > 1.0) {
        _progress = 1.0;
    }
    
    CGFloat origin = self.lineWidth + originXY;
    CGFloat width = self.bounds.size.width - origin * 2;
    width *= _progress;
    if (width > self.bounds.size.width - origin * 2) {
        width = self.bounds.size.width - origin * 2;
    }
    CGFloat height = self.bounds.size.height - origin * 2;
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.frame = CGRectMake(origin, origin, width, height);
    }];
    //
    self.label.text = [NSString stringWithFormat:@"%.0f%%", (_progress * 100.0)];
}

- (void)initializeProgress
{
    //
    [self bringSubviewToFront:self.label];
    //
    self.backgroundColor = self.defaultColor;
    self.lineView.layer.borderColor = self.lineColor.CGColor;
    self.progressView.backgroundColor = self.progressColor;
    self.lineView.layer.borderWidth = self.lineWidth;
    //
    if (self.layer.cornerRadius > self.frame.size.height) {
        self.layer.cornerRadius = self.frame.size.height / 2;
    }
    self.label.layer.cornerRadius = self.layer.cornerRadius;
    self.progressView.layer.cornerRadius = (self.layer.cornerRadius - (self.lineWidth + originXY));
    self.lineView.layer.cornerRadius = self.layer.cornerRadius;
    //
    if (self.frame.size.height < self.lineWidth) {
        self.lineView.hidden = YES;
    }
    
    self.progress = 0.0;
}

@end
