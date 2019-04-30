//
//  SYWaveProgressView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/11/15.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "SYWaveProgressView.h"

@interface SYWaveProgressView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat wave_amplitude; /// 振幅a（y = asin(wx+φ) + k）
@property (nonatomic, assign) CGFloat wave_cycle; /// 周期w
@property (nonatomic, assign) CGFloat wave_h_distance; /// 两个波水平之间偏移
@property (nonatomic, assign) CGFloat wave_v_distance; /// 两个波竖直之间偏移
@property (nonatomic, assign) CGFloat wave_scale; /// 水波速率
@property (nonatomic, assign) CGFloat wave_offsety; /// 波峰所在位置的y坐标
@property (nonatomic, assign) CGFloat wave_move_width; /// 移动的距离，配合速率设置
@property (nonatomic, assign) CGFloat wave_offsetx; /// 偏移
@property (nonatomic, assign) CGFloat offsety_scale; /// 上升的速度

@end

@implementation SYWaveProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat size = MIN(frame.size.width, frame.size.height);
        CGRect rect = self.frame;
        rect.size = CGSizeMake(size, size);
        self.frame = rect;
        
        // 振幅
        _wave_amplitude = self.frame.size.height / 25;
        // 周期
        _wave_cycle = 2 * M_PI / (self.frame.size.width * 0.9);
        // 两个波水平之间偏移
        _wave_h_distance = 2 * M_PI / _wave_cycle * 0.6;
        // 两个波竖直之间偏移
        _wave_v_distance = _wave_amplitude * 0.4;
        // 移动的距离，配合速率设置
        _wave_move_width = 0.5;
        // 水波速率
        _wave_scale = 0.4;
        // 上升的速度
        _offsety_scale = 0.1;
        // 波峰所在位置的y坐标，刚开始的时候_wave_offsety是最大值
       _wave_offsety = (self.frame.size.height + 2 * _wave_amplitude);
        
        self.backgroundColor = [UIColor clearColor];
        [self addDisplayLinkAction];
    }
    return self;
}

#pragma mark - 波纹动画

- (void)addDisplayLinkAction
{
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)displayLinkAction
{
    self.wave_offsetx += (self.wave_move_width * self.wave_scale);
    if (self.wave_offsety <= 0.01) {
        [self removeDisplayLinkAction];
    }
    [self setNeedsDisplay];
}

- (void)removeDisplayLinkAction
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark - 绘图

- (void)drawRect:(CGRect)rect
{
    self.label.text = [NSString stringWithFormat:@"%.0f%%", (self.progress * 100.0)];
    
    CGRect pathRect = rect;
    if (self.showBorderline) {
        pathRect = CGRectMake(self.lineWidth, self.lineWidth, (rect.size.width - self.lineWidth * 2), (rect.size.height - self.lineWidth * 2));
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    // 背景颜色
    [self.defaultColor setFill];
    [path fill];
    // 边框颜色
    if (self.showBorderline) {
        path.lineWidth = self.lineWidth;
        [self.lineColor setStroke];
        [path stroke];
    }
    //
    [path addClip];
    
    // 绘制两个波形图
    [self drawWaveColor:self.progressColor offsetx:0 offsety:0];
    [self drawWaveColor:[self.progressColor colorWithAlphaComponent:0.6] offsetx:self.wave_h_distance offsety:self.wave_v_distance];
}

- (void)drawWaveColor:(UIColor *)color offsetx:(CGFloat)offsetx offsety:(CGFloat)offsety
{
    // 波浪动画，进度的实际操作范围是，多加上两个振幅的高度，到达设置进度的位置y
    CGFloat end_offY = (1.0 - self.progress) * (self.frame.size.height + 2 * self.wave_amplitude);
    if (self.wave_offsety != end_offY) {
        if (end_offY < self.wave_offsety) {
            self.wave_offsety = MAX(self.wave_offsety -= (self.wave_offsety - end_offY) * self.offsety_scale, end_offY);
        } else {
            self.wave_offsety = MIN(self.wave_offsety += (end_offY - self.wave_offsety) * self.offsety_scale, end_offY);
        }
    }
    
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    for (float next_x = 0.0f; next_x <= self.frame.size.width; next_x++) {
        // 正弦函数，绘制波形
        CGFloat next_y = self.wave_amplitude * sin(self.wave_cycle * next_x + self.wave_offsetx + offsetx / self.bounds.size.width * 2 * M_PI) + self.wave_offsety + offsety;
        if (next_x == 0) {
            [wavePath moveToPoint:CGPointMake(next_x, next_y - self.wave_amplitude)];
        } else {
            [wavePath addLineToPoint:CGPointMake(next_x, next_y - self.wave_amplitude)];
        }
    }
    
    [wavePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [wavePath addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    [color set];
    [wavePath fill];
}

#pragma mark - getter

#pragma mark - getter

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
    
    [self addDisplayLinkAction];
}

- (void)initializeProgress
{
    [self bringSubviewToFront:self.label];
    self.label.layer.cornerRadius = self.layer.cornerRadius;
    self.label.text = [NSString stringWithFormat:@"%.0f%%", (_progress * 100.0)];
    
    self.progress = 0.0;
}

@end
