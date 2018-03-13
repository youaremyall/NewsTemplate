//
//  UIVideoPlayerViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/25.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIVideoPlayerViewController.h"
#import "XLVideoPlayer.h"
#import "Globals.h"

@interface UIVideoPlayerViewController ()

@property (strong, nonatomic) XLVideoPlayer *player;

@end

@implementation UIVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIControls];
    [self setMoviePlayer:nil];
    
    //上传文章属性统计数据
    [self syncDocAnalytics:[self.dict objectForVitualKey:@"docId"] action:actionTypePlay completion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {

    [self.player destroyPlayer];
    self.player = nil;
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化
- (void)initUIControls {
    
    self.navbar.backgroundColor = [UIColor clearColor];
    [self.navbar.barRight setHidden:YES];
    
    [self initUIMoviePlayer];
}

- (void) initUIMoviePlayer {
    
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9/16);
    UIView *__view = [[UIView alloc] initWithFrame:frame];
    __view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:__view];
    
    self.player = [[XLVideoPlayer alloc] init];
    self.player.frame = __view.bounds;
    self.player.closeHidden = YES;
    self.player.closeBlock = ^(XLVideoPlayer *player) {
        
    };
    [self.view addSubview:self.player];
    [self.view bringSubviewToFront:self.navbar];
}

#pragma mark -界面设置
- (void) setMoviePlayer:(NSDictionary *)JSON {
    
    //CCTV15-音乐频道 直播源地址
    self.player.videoUrl = @"http://183.251.61.207/PLTV/88888888/224/3221225818/index.m3u8";
}

@end
