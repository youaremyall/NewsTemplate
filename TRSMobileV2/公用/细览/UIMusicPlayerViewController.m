//
//  UIAudioPlayerViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/25.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIMusicPlayerViewController.h"
#import "MPMusicPlayer.h"
#import "XZMStatusBarHUD.h"
#import "Globals.h"

#define  kUIMusicPlayerLoops  @[@"顺序播放", @"单曲循环", @"随机播放"]

@interface UIMusicPlayerViewController () <MPMusicPlayerDelegate, UIScrollViewDelegate> {
    
    /*整体背景*/
    __strong UIImageView *_imageAllBG;
    
    /*顶部图层*/
    __strong UIButton *_buttonLeft;
    __strong UIButton *_buttonRight;

    /*中间区域*/
    __strong UIScrollView *_scrollView;
    __strong UIPageControl *_pageControl;
    
    /*进度图层*/
    __strong UIView *_viewProgress;
    __strong UILabel *_labelPlayingTime;
    __strong UILabel *_labelDurationTime;
    __strong UIProgressView *_musicProgress;
    __strong UISlider *_musicSlider;

    /*控制图层*/
    __strong UIView *_viewControl;
    __strong UIButton *_buttonLoop;
    __strong UIButton *_buttonPrev;
    __strong UIButton *_buttonNext;
    __strong UIButton *_buttonPlayPause;
    __strong UIButton *_buttonPlaylist;
    
    /*歌曲信息图层*/
    
    /*专辑图层*/
    __strong UIView      *_layerMusic;
    __strong UIImageView *_imageMusic;
    __strong UILabel *_labelTitle;
    __strong UILabel *_labelSinger;
    __strong UIButton *_buttonFavorite;
    
    /*歌词图层*/
    __strong UIView     *_layerLyric;

    /*播放循环模式*/
    AVPlayerLoop             _playerLoop;
}
@end

@implementation UIMusicPlayerViewController

+ (instancetype)sharedInstance {
    
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self initUIControls];
    [self setMusicPlayerContent];
    addNotificationObserver(self, @selector(applicationWillEnterForeground:), UIApplicationWillEnterForegroundNotification, nil);
}

- (void)viewWillAppear:(BOOL)animated {

    [self updateMusicPlaying];
    [[XZMStatusBarHUD sharedInstance] hidden];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self updateMusicPlaying];
}

#pragma mark -
- (void) initUIControls {

    self.view.backgroundColor = [UIColor whiteColor];
    [self initUIMusicControl];
    [MPMusicPlayer sharedPlayer].numberOfLoops = _playerLoop;
    [MPMusicPlayer sharedPlayer].delegate = self;
}

- (void) initUIMusicControl {

    [self initUIMusicPlayer];
    [self initUIMusicAlbum];
    [self initUIMusicLyric];
}

- (void) initUIMusicPlayer {

    /*整体背景*/
    _imageAllBG = [[UIImageView alloc] init];
    _imageAllBG.contentMode = UIViewContentModeScaleAspectFill;
    _imageAllBG.image = [UIImage imageNamed:@"MPMusicPlayer.bundle/图片_背景.jpg"];
    [self.view addSubview:_imageAllBG];
    
    _imageAllBG.sd_layout
    .topSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0);
    
    /*顶部图层*/
    _buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonLeft.tag = -1;
    _buttonLeft.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [_buttonLeft setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/关闭.png"] forState:UIControlStateNormal];
    [_buttonLeft addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonLeft];
    
    _buttonLeft.sd_layout
    .topSpaceToView(self.view, 0)
    .leftSpaceToView(self.view, 0)
    .widthIs(64.0)
    .heightIs(64.0);

    
    _buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonRight.tag = -2;
    _buttonRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [_buttonRight setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/更多.png"] forState:UIControlStateNormal];
    [_buttonRight addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonRight];

    _buttonRight.sd_layout
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .widthIs(64.0)
    .heightIs(64.0);

    /*控制图层*/
    _viewControl = [[UIView alloc] init];
    _viewControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_viewControl];
    
    _viewControl.sd_layout
    .bottomSpaceToView(self.view, 44.0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(60.0);
    
    _playerLoop = [[NSUserDefaults standardUserDefaults] integerForKey:@"musicplayer.Loop"];
    _buttonLoop = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonLoop.tag = 3;
    [_buttonLoop setImage:[UIImage imageNamed:[NSString stringWithFormat:@"MPMusicPlayer.bundle/%@", kUIMusicPlayerLoops[_playerLoop]] ]
                 forState:UIControlStateNormal];
    [_buttonLoop addTarget:self action:@selector(didPlayControlSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewControl addSubview:_buttonLoop];
    
    _buttonLoop.sd_layout
    .topSpaceToView(_viewControl, 0)
    .bottomSpaceToView(_viewControl, 0)
    .leftSpaceToView(_viewControl, 0)
    .widthIs(CGRectGetHeight(_viewControl.frame));
    
    
    _buttonPlaylist = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonPlaylist.tag = 4;
    [_buttonPlaylist setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_播放列表.png"] forState:UIControlStateNormal];
    [_buttonPlaylist addTarget:self action:@selector(didPlayControlSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewControl addSubview:_buttonPlaylist];
    
    _buttonPlaylist.sd_layout
    .topSpaceToView(_viewControl, 0)
    .bottomSpaceToView(_viewControl, 0)
    .rightSpaceToView(_viewControl, 0)
    .widthIs(CGRectGetHeight(_viewControl.frame));

    
    _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonPlayPause.tag = 0;
    [_buttonPlayPause setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_播放.png"] forState:UIControlStateNormal];
    [_buttonPlayPause setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_暂停.png"] forState:UIControlStateSelected];
    [_buttonPlayPause addTarget:self action:@selector(didPlayControlSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewControl addSubview:_buttonPlayPause];
    
    _buttonPlayPause.sd_layout
    .topSpaceToView(_viewControl, 0)
    .bottomSpaceToView(_viewControl, 0)
    .centerXEqualToView(_viewControl)
    .widthIs(CGRectGetHeight(_viewControl.frame));

    
    _buttonPrev = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonPrev.tag = 1;
    [_buttonPrev setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_上一曲.png"] forState:UIControlStateNormal];
    [_buttonPrev addTarget:self action:@selector(didPlayControlSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewControl addSubview:_buttonPrev];
    
    _buttonPrev.sd_layout
    .topSpaceToView(_viewControl, 0)
    .bottomSpaceToView(_viewControl, 0)
    .rightSpaceToView(_buttonPlayPause, 8.0)
    .widthIs(CGRectGetHeight(_viewControl.frame));

    
    _buttonNext = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonNext.tag = 2;
    [_buttonNext setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_下一曲.png"] forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(didPlayControlSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewControl addSubview:_buttonNext];
    
    _buttonNext.sd_layout
    .topSpaceToView(_viewControl, 0)
    .bottomSpaceToView(_viewControl, 0)
    .leftSpaceToView(_buttonPlayPause, 8.0)
    .widthIs(CGRectGetHeight(_viewControl.frame));
    

    /*进度图层*/
    _viewProgress = [[UIView alloc] init];
    _viewProgress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_viewProgress];
    
    _viewProgress.sd_layout
    .bottomSpaceToView(_viewControl, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(40.0);
    
    
    _labelPlayingTime = [[UILabel alloc] init];
    _labelPlayingTime.backgroundColor = [UIColor clearColor];
    _labelPlayingTime.textAlignment = NSTextAlignmentCenter;
    _labelPlayingTime.textColor = [UIColor whiteColor];
    _labelPlayingTime.font = [UIFont systemFontOfSize:14.0];
    _labelPlayingTime.text = @"00:00";
    [_viewProgress addSubview:_labelPlayingTime];
    
    _labelPlayingTime.sd_layout
    .topSpaceToView(_viewProgress, 0)
    .bottomSpaceToView(_viewProgress, 0)
    .leftSpaceToView(_viewProgress, 8.0)
    .widthIs(48.0);

    
    _labelDurationTime = [[UILabel alloc] init];
    _labelDurationTime.backgroundColor = [UIColor clearColor];
    _labelDurationTime.textAlignment = NSTextAlignmentCenter;
    _labelDurationTime.textColor = [UIColor whiteColor];
    _labelDurationTime.font = [UIFont systemFontOfSize:14.0];
    _labelDurationTime.text = @"00:00";
    [_viewProgress addSubview:_labelDurationTime];
    
    _labelDurationTime.sd_layout
    .topSpaceToView(_viewProgress, 0)
    .bottomSpaceToView(_viewProgress, 0)
    .rightSpaceToView(_viewProgress, 8.0)
    .widthIs(48.0);

    
    _musicProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _musicProgress.backgroundColor = [UIColor clearColor];
    _musicProgress.trackTintColor = [UIColor whiteColor];
    _musicProgress.progressTintColor = [UIColor lightGrayColor];
    [_viewProgress addSubview:_musicProgress];
    
    _musicProgress.sd_layout
    .leftSpaceToView(_labelPlayingTime, 4)
    .rightSpaceToView(_labelDurationTime, 4)
    .centerXEqualToView(_viewProgress)
    .centerYEqualToView(_viewProgress);
    
    
    _musicSlider = [[UISlider alloc] init];
    _musicSlider.continuous = NO;
    _musicSlider.backgroundColor = [UIColor clearColor];
    _musicSlider.maximumTrackTintColor = [UIColor clearColor];
    _musicSlider.minimumTrackTintColor = [UIColor colorWithRGB:0x31c27c alpha:1.0];
    [_musicSlider setThumbImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_滑块.png"] forState:UIControlStateNormal];
    [_musicSlider setThumbImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/音乐_滑块.png"] forState:UIControlStateHighlighted];
    [_musicSlider addTapGesture:self selector:@selector(didSliderTaped:)];
    [_musicSlider addTarget:self action:@selector(didSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_viewProgress addSubview:_musicSlider];

    _musicSlider.sd_layout
    .leftSpaceToView(_labelPlayingTime, 2)
    .rightSpaceToView(_labelDurationTime, 2)
    .centerXEqualToView(_viewProgress)
    .centerYEqualToView(_viewProgress);

    /*中间区域*/
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.numberOfPages = 3;
    [self.view addSubview:_pageControl];
    
    _pageControl.sd_layout
    .bottomSpaceToView(_viewProgress, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(16.0);

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    CGFloat h = CGRectGetHeight(self.view.frame) - CGRectGetHeight(_buttonLeft.frame)
                - CGRectGetHeight(_viewProgress.frame) - CGRectGetHeight(_viewControl.frame) - 44.0;
    _scrollView.sd_layout
    .xIs(0)
    .yIs(CGRectGetHeight(_buttonLeft.frame))
    .widthIs(CGRectGetWidth(self.view.frame))
    .heightIs(h);
    
    _scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    
    /*毛玻璃效果*/
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = [UIScreen mainScreen].bounds;
    [_imageAllBG insertSubview:blurEffectView atIndex:0];
}

- (void) initUIMusicAlbum {

    _layerMusic = [[UIView alloc] init];
    _layerMusic.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_layerMusic];
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_scrollView.frame), 0) animated:YES];
    
    _layerMusic.sd_layout
    .xIs(CGRectGetWidth(_scrollView.frame))
    .yIs(0)
    .widthIs(CGRectGetWidth(_scrollView.frame))
    .heightIs(CGRectGetHeight(_scrollView.frame));
    
    _labelSinger = [[UILabel alloc] init];
    _labelSinger.backgroundColor = [UIColor clearColor];
    _labelSinger.textColor = [UIColor whiteColor];
    _labelSinger.textAlignment = NSTextAlignmentCenter;
    _labelSinger.font = [UIFont systemFontOfSize:15.0];
    _labelSinger.text = @"薛之谦";
    [_layerMusic addSubview:_labelSinger];
    
    CGFloat margin = CGRectGetHeight(_layerMusic.frame) /2.0 - 120.0;
    _labelSinger.sd_layout
    .bottomSpaceToView(_layerMusic, margin)
    .leftSpaceToView(_layerMusic, 8.0)
    .rightSpaceToView(_layerMusic, 8.0)
    .heightIs(21.0);

    _labelTitle = [[UILabel alloc] init];
    _labelTitle.backgroundColor = [UIColor clearColor];
    _labelTitle.textColor = [UIColor whiteColor];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.font = [UIFont systemFontOfSize:20.0];
    _labelTitle.text = @"我好像在哪见过你";
    [_layerMusic addSubview:_labelTitle];
    
    _labelTitle.sd_layout
    .bottomSpaceToView(_labelSinger, 8.0)
    .leftSpaceToView(_layerMusic, 8.0)
    .rightSpaceToView(_layerMusic, 8.0)
    .heightIs(21.0);
    
    _buttonFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonFavorite.tag = 0;
    _buttonFavorite.hidden = YES;
    [_buttonFavorite setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/收藏_未选.png"] forState:UIControlStateNormal];
    [_buttonFavorite setImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/收藏_选中.png"] forState:UIControlStateSelected];
    [_buttonFavorite addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_layerMusic addSubview:_buttonFavorite];
    
    _buttonFavorite.sd_layout
    .centerYEqualToView(_labelTitle)
    .leftSpaceToView(_layerMusic, 0)
    .widthIs(48.0)
    .heightIs(48.0);
    
    _imageMusic = [[UIImageView alloc] init];
    _imageMusic.contentMode = UIViewContentModeScaleAspectFill;
    _imageMusic.clipsToBounds = YES;
    [_layerMusic addSubview:_imageMusic];
    
    CGFloat size = 200.0;
    if(CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size)) size = 180.0;
    
    _imageMusic.sd_layout
    .bottomSpaceToView(_labelTitle, 16.0)
    .widthIs(size)
    .heightIs(size)
    .centerXEqualToView(_layerMusic);
    
    [_imageMusic setBorderWithColor:[UIColor colorWithWhite:0 alpha:0.6] borderWidth:10.0];
    [_imageMusic setCornerWithRadius:CGRectGetHeight(_imageMusic.frame)/2.0];
}

- (void)initUIMusicLyric {

    _layerLyric = [[UIView alloc] init];
    _layerLyric.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_layerLyric];

    _layerLyric.sd_layout
    .xIs(2*CGRectGetWidth(_scrollView.frame))
    .yIs(0)
    .widthIs(CGRectGetWidth(_scrollView.frame))
    .heightIs(CGRectGetHeight(_scrollView.frame));
}

#pragma mark -
- (void)setMusicPlayerContent {
    
    [AFHTTP request:@"file://音乐测试.json" completion:^(BOOL success, id _Nullable response, NSError * _Nullable error) {
        
        [[MPMusicPlayer sharedPlayer] setPlayItems:response[@"data"] ];
        [self updateMusicSong];
    }];
}

- (void)startMusicRotation {

    if(![_imageMusic.layer animationForKey:@"rotation"]) {
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        
        rotationAnimation.duration = 8.0;
        rotationAnimation.repeatCount = FLT_MAX;
        rotationAnimation.cumulative = NO;
        [_imageMusic.layer addAnimation:rotationAnimation forKey:@"rotation"];
    }
    
    //start Animation
    CFTimeInterval pausedTime = [_imageMusic.layer timeOffset];
    _imageMusic.layer.speed = 1.0;
    _imageMusic.layer.timeOffset = 0.0;
    _imageMusic.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [_imageMusic.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    _imageMusic.layer.beginTime = timeSincePause;
}

- (void)stopMusicRotation {

    CFTimeInterval pausedTime = [_imageMusic.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    _imageMusic.layer.speed = 0.0;
    _imageMusic.layer.timeOffset = pausedTime;
}

- (void)updateMusicSong {

    NSDictionary *dict = [MPMusicPlayer sharedPlayer].currentPlayingMusic;
    
    _labelTitle.text = dict[kMusicName];
    _labelSinger.text = dict[kMusicArtist];
    [_buttonFavorite setSelected:[StroageService hasValueForKey:dict[kMusicUrl] serviceType:serviceTypeFavorite] ];
    
    [_imageMusic setUIImageWithURL:dict[kMusicArtwork]
                  placeholderImage:[UIImage imageNamed:@"MPMusicPlayer.bundle/图片_专辑.jpg"]
                         completed:nil];
    
    [_viewProgress setHidden:[MPMusicPlayer sharedPlayer].isLive ];
    
    [[XZMStatusBarHUD sharedInstance] setHUDMessmage:[NSString stringWithFormat:@"正在播放: %@", _labelTitle.text]
                                               image:[UIImage imageNamed:@"MPMusicPlayer.bundle/状态栏_播放.png"] ];
}

- (void)updateMusicPlaying {

    BOOL isPlaying = [MPMusicPlayer sharedPlayer].isPlaying;
    [_buttonPlayPause setSelected:isPlaying];
    (isPlaying ? [self startMusicRotation] : [self stopMusicRotation]);
    
    [[XZMStatusBarHUD sharedInstance] setHUDMessmage:[NSString stringWithFormat:@"%@: %@", (isPlaying ? @"正在播放" : @"暂停播放"), _labelTitle.text]
                                               image:[UIImage imageNamed:[NSString stringWithFormat:@"MPMusicPlayer.bundle/%@", (isPlaying ? @"状态栏_播放.png" : @"状态栏_暂停")] ] ];
}

#pragma mark - 事件处理
- (IBAction)didButtonSelect:(id)sender {

    NSUInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case -1: //关闭
        {
            [self dismissViewControllerAnimated:YES
                                     completion:^(){
                                         if(![MPMusicPlayer sharedPlayer].isPlaying) return;
                                         
                                         NSString *musicName = [MPMusicPlayer sharedPlayer].currentPlayingMusic[kMusicName];
                                         XZMStatusBarHUD *hud = [XZMStatusBarHUD sharedInstance];
                                         [hud showMessage:[NSString stringWithFormat:@"正在播放: %@", musicName]
                                                    image:[UIImage imageNamed:@"MPMusicPlayer.bundle/状态栏_播放.png"]
                                                 position:0
                                               animaDelay:0
                                                   hidden:NO
                                            configuration:^{
                                                [XZMStatusBarHUD sharedInstance].statusAlpha = 1.0f;
                                                [XZMStatusBarHUD sharedInstance].windowLevel = UIWindowLevelAlert;
                                                [XZMStatusBarHUD sharedInstance].statusColor = _musicSlider.minimumTrackTintColor;
                                            }];
                                         
                                         hud.statusBarBlock = ^() {
                                             [GDelegate.navTab presentViewController:[UIMusicPlayerViewController sharedInstance]
                                                                                     animated:YES
                                                                                   completion:^{
                                                                                   }];
                                         };
                                     }];
            break;
        }
            
        case -2: //更多
            break;
        case 0:  //收藏
        {
            [_buttonFavorite setSelected:!_buttonFavorite.selected];
            
            NSDictionary *music = [MPMusicPlayer sharedPlayer].currentPlayingMusic;
            NSString *musicUrl = music[kMusicUrl];
            if(_buttonFavorite.selected) {
                [StroageService setValue:music forKey:musicUrl serviceType:serviceTypeFavorite];
            }
            else {
                [StroageService removeValueForKey:musicUrl serviceType:serviceTypeFavorite];
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)didPlayControlSelect:(id)sender {

    NSUInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 0: //播放暂停
            [[MPMusicPlayer sharedPlayer] playPause];
            [[MPMusicPlayer sharedPlayer] setIsStopByUser:_buttonPlayPause.selected];
            break;
        case 1: //上一曲
            [[MPMusicPlayer sharedPlayer] playPrev];
            break;
        case 2: //下一曲
            [[MPMusicPlayer sharedPlayer] playNext];
            break;
        case 3: //循环控制
            {
                ++_playerLoop;
                if(_playerLoop > AVPlayerLoopRandom) {_playerLoop = AVPlayerLoopAll;}
                [NSUserDefaults setObjectForKey:@(_playerLoop) key:@"musicplayer.Loop"];
                [_buttonLoop setImage:[UIImage imageNamed:[NSString stringWithFormat:@"MPMusicPlayer.bundle/%@", kUIMusicPlayerLoops[_playerLoop]] ]
                             forState:UIControlStateNormal];
                [MPMusicPlayer sharedPlayer].numberOfLoops = _playerLoop;
                
                [[XZMStatusBarHUD sharedInstance] showMessage:[NSString stringWithFormat:@"已切换到%@模式", kUIMusicPlayerLoops[_playerLoop]]
                                                        image:[UIImage imageNamed:@"MPMusicPlayer.bundle/提示_成功.png"]
                                                     position:0
                                                   animaDelay:0
                                                configuration:^{
                                                   [XZMStatusBarHUD sharedInstance].statusH = 64.0;
                                                   [XZMStatusBarHUD sharedInstance].statusColor = _musicSlider.minimumTrackTintColor;
                                               }];
                break;
            }
    }
}

- (IBAction)didSliderValueChanged:(id)sender {

    MPMusicPlayer *player = [MPMusicPlayer sharedPlayer];
    [player seekToTime:CMTimeMake(player.duration * ((UISlider *)sender).value, 1)];
}

- (IBAction)didSliderTaped:(UITapGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:recognizer.view];
    CGFloat value = location.x / CGRectGetWidth(recognizer.view.frame);
    [(UISlider *)recognizer.view setValue:value animated:YES];
    
    MPMusicPlayer *player = [MPMusicPlayer sharedPlayer];
    [player seekToTime:CMTimeMake(player.duration * value, 1)];
}

#pragma mark - MPMusicPlayerDelegate

/**
 * 播放歌曲已切换
 */
- (void)didAVPlayerItemChange:(MPMusicPlayer *)player {

    [self updateMusicSong];
}

/**
 * 播放状态更改
 */
- (void)didAVPlayerItemRateChange:(MPMusicPlayer *)player {
    
    [self updateMusicPlaying];
}

/**
 * 播放进度更新
 */
- (void)didAVPlayerItemTrackingTime:(float)currentTime duration:(float)duration {

    _labelPlayingTime.text = [NSString videoPlayTimeValue:currentTime];
    _labelDurationTime.text = [NSString videoPlayTimeValue:duration];
    [_musicSlider setValue:(currentTime / duration) animated:YES];
}

/**
 * 缓冲进度更新
 */
- (void)didAVPlayerItemLoadedTimeRange:(float)progress {

    [_musicProgress setProgress:progress animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    NSInteger index = scrollView.contentOffset.x / self.view.bounds.size.width;
    [_pageControl setCurrentPage:index];
}

@end
