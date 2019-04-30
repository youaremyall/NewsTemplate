//
//  SYRingProgressView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/11/15.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "SYRingProgressView.h"

@interface SYRingProgressView ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation SYRingProgressView

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
    // 路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    // 线宽
    path.lineWidth = self.lineWidth;
    // 颜色
    [self.progressColor set];
    // 拐角
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    // 半径
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - self.lineWidth) * 0.5;
    // 画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    // 连线
    [path stroke];
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
    
    self.label.text = [NSString stringWithFormat:@"%.0f%%", (_progress * 100.0)];
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
