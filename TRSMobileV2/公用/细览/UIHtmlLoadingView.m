//
//  UIHtmlLoadingView.m
//  NXXW
//
//  Created by TRS on 17/2/10.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import "UIHtmlLoadingView.h"
#import "FBShimmeringView.h"
#import "Globals.h"

@interface UIHtmlLoadingView ()

@property (strong, nonatomic) FBShimmeringView  *shimmeringView;

@end

@implementation UIHtmlLoadingView

- (instancetype) initWithFrame:(CGRect)frame {

    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRGB:0xf9f9f9];
    
        //动画遮罩
        _shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.bounds];
        _shimmeringView.shimmering = YES;
        _shimmeringView.shimmeringBeginFadeDuration = 0.3;
        _shimmeringView.shimmeringOpacity = 0.2;
        [self addSubview:_shimmeringView];

        //应用图标
        UILabel *label = [[UILabel alloc] initWithFrame:_shimmeringView.frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:36.0];
        label.text = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
        [self addSubview:label];
        _shimmeringView.contentView = label;
    }
    return self;
}


/**
 * 开启动画
 */
- (void)startAmination {

    _shimmeringView.shimmering = YES;
}

/**
 * 停止动画
 */
- (void)stopAnimation {

    [UIView animateWithDuration:0.0
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _shimmeringView.shimmering = NO;
                         [self removeFromSuperview];
                     }];
}

@end
