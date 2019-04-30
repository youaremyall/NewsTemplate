//
//  SYPieProgressView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/11/15.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "SYPieProgressView.h"

@interface SYPieProgressView ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation SYPieProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat size = MIN(frame.size.width, frame.size.height);
        CGRect rect = self.frame;
        rect.size = CGSizeMake(size, size);
        self.frame = rect;
        
        self.backgroundColor = [UIColor clearColor];
        self.lineView.frame = self.bounds;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.label.text = [NSString stringWithFormat:@"%.0f%%", (self.progress * 100.0)];
    
    CGRect pathRect = rect;
    if (self.showBorderline) {
        pathRect = CGRectMake(self.lineWidth, self.lineWidth, (rect.size.width - self.lineWidth * 2), (rect.size.height - self.lineWidth * 2));
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    // 背景颜色
    [self.progressColor setFill];
    [path fill];
    //
    [path addClip];
    //
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    CGFloat radius = MIN(pathRect.size.width, pathRect.size.height) * 0.5 - self.lineWidth;
    // 进度
    [self.defaultColor set];
    if (self.progress >= 1.0) {
        [self.progressColor set];
    }
    // 进程圆
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextMoveToPoint(context, xCenter, yCenter);
    CGContextAddLineToPoint(context, xCenter, 0);
    CGFloat endAngle = -M_PI * 0.5 + self.progress * M_PI * 2 + 0.001;
    CGContextAddArc(context, xCenter, yCenter, radius, -M_PI * 0.5, endAngle, 1);
    CGContextFillPath(context);
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
    
    [self setNeedsDisplay];
}

- (void)initializeProgress
{
    [self bringSubviewToFront:self.label];
    self.label.layer.cornerRadius = self.layer.cornerRadius;
    self.label.text = [NSString stringWithFormat:@"%.0f%%", (_progress * 100.0)];
    //
    self.lineView.layer.borderColor = self.lineColor.CGColor;
    self.lineView.layer.borderWidth = self.lineWidth;
    self.lineView.layer.cornerRadius = self.frame.size.width / 2;
    [self sendSubviewToBack:self.lineView];
    
    self.progress = 0.0;
}

@end
