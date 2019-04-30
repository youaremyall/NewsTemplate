//
//  SYProgressView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/11/15.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "SYProgressView.h"

@implementation SYProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label.hidden = YES;
        
        self.layer.masksToBounds = YES;
        
        _progressColor = [UIColor blueColor];
        _defaultColor = [UIColor lightGrayColor];
        _lineColor = [UIColor blackColor];
        _lineWidth = 1.0;
    }
    return self;
}

#pragma mark - getter

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.label];
        _label.layer.masksToBounds = YES;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

#pragma mark - setter

#pragma mark - 初始化方法

- (void)initializeProgress
{
    
}

@end
