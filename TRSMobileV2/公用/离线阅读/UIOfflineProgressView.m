//
//  NSOfflineStatusView.m
//  TRSMobile
//
//  Created by TRS on 14-6-6.
//  Copyright (c) 2014年 TRS. All rights reserved.
//

#import "UIOfflineProgressView.h"
#import "NSOfflineManager.h"
#import "UIColor+Extension.h"
#import "UIView+Extension.h"

@interface UIOfflineProgressView ()

@property (nonatomic, retain) NSOfflineManager *offlineManager;
@property (nonatomic, retain) UIView  *progress;
@property (nonatomic, retain) UILabel *label;

@end

@implementation UIOfflineProgressView

+ (void)show {
    
    UIOfflineProgressView *instance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds ];
    
    [instance performSelector:@selector(startOfflineDownloading) withObject:nil afterDelay:0.3];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // Initialization code
        self.hidden = NO;
        self.windowLevel = UIWindowLevelNormal;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        UIView *statusView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        statusView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        [self addSubview:statusView];
        
        self.progress = [[UIView alloc] initWithFrame:statusView.bounds];
        self.progress.width = 0.0f;
        self.progress.backgroundColor = [UIColor colorWithRGB:0x238cf7 alpha:1.0];
        [self addSubview:self.progress];
        
        self.label = [[UILabel alloc] initWithFrame:statusView.frame];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont systemFontOfSize:13.0];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.text = @"开始离线";
        [self addSubview:self.label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(statusView.frame.size.width - 60.0, 0.0, 60.0, statusView.frame.size.height);
        button.imageEdgeInsets = UIEdgeInsetsMake(2.0, 30.0, 2.0, 0.0);
        [button setImage:[UIImage imageNamed:@"normal.bundle/离线_关闭.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelOfflineDownloading) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void)startOfflineDownloading {
    
    id callback = ^(NSString * _Nonnull channelName, float percent, BOOL finish) {
        if(finish) {
            [self stopOfflineDownloading];
        }
        else {
            self.progress.width = CGRectGetWidth(self.frame) * percent/100;
            self.label.text = [NSString stringWithFormat:@"正在离线 : %@ (%0.2f%%)", channelName, percent];
        }
    };
    
    _offlineManager = [[NSOfflineManager alloc] init];
    _offlineManager.callback = callback;
    [_offlineManager offlineManagerDownloading:NO];
}

- (void)stopOfflineDownloading {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }
    ];
}

- (void)cancelOfflineDownloading {
    
    [_offlineManager offlineManagerDownloading:YES];
    [self stopOfflineDownloading];
}

@end
