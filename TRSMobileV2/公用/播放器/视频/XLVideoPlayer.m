//
//  XLVideoPlayer.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import "XLVideoPlayer.h"
#import "XLSlider.h"

static CGFloat const barAnimateSpeed = 0.5f;
static CGFloat const barShowDuration = 5.0f;
static CGFloat const opacity = 1.0f;
static CGFloat const bottomBaHeight = 40.0f;
static CGFloat const playBtnSideLength = 60.0f;

@interface XLVideoPlayer ()

/**videoPlayer superView*/
@property (nonatomic, strong) UIView *playSuprView;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UILabel *totalDurationLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) XLSlider *slider;
@property (nonatomic, strong) UIWindow *keyWindow;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) CGRect playerOriginalFrame;
@property (nonatomic, strong) UIButton *zoomScreenBtn;

/**video player*/
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/**video total duration*/
@property (nonatomic, assign) CGFloat totalDuration;
@property (nonatomic, assign) CGFloat current;

@property (nonatomic, strong) UITableView *bindTableView;
@property (nonatomic, assign) CGRect currentPlayCellRect;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, assign) BOOL isOriginalFrame;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL barHiden;
@property (nonatomic, assign) BOOL inOperation;
@property (nonatomic, assign) BOOL smallWinPlaying;

/*此标识用于记录进入后台前的播放状态，用于切换到前台后判断是否继续播放?*/
@property (nonatomic, assign) BOOL isPlayingBeforeResignActive;

/*此标识用于避免网络状态发生更改时，重复多次弹出节约流量提示*/
@property (nonatomic, assign) BOOL isPresentAlert;
@property (nonatomic, assign) BOOL isLocalFilePlay;

@end

@implementation XLVideoPlayer

#pragma mark - public method

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor blackColor];
        
        self.keyWindow = [UIApplication sharedApplication].keyWindow;

        //show or hiden gestureRecognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHidenBar)];
        [self addGestureRecognizer:tap];

        //screen orientation change && add the observer.
        [self addNotificationCenterObserver];

        self.barHiden = YES;
    }
    return self;
}

- (void)setVideoUrl:(NSString *)videoUrl {
   
        _videoUrl = videoUrl;
    [self.layer addSublayer:self.playerLayer];
    [self insertSubview:self.activityIndicatorView belowSubview:self.playOrPauseBtn];
    [self.activityIndicatorView startAnimating];
    //play from start
    [self playOrPause:self.playOrPauseBtn];
    [self addSubview:self.topBar];
    [self addSubview:self.bottomBar];
    [self insertSubview:self.playOrPauseBtn aboveSubview:self.activityIndicatorView];
    
    //whether is onlive play.
    BOOL isLive = [videoUrl.pathExtension isEqualToString:@"m3u8"];
    _progressLabel.hidden = _totalDurationLabel.hidden = _slider.hidden = isLive;
    
    //弹出正在使用移动网络，继续播放将消耗流量
    [self afNetworkingReachabilityViaWWANAlert];
}

- (void)playPause {
    [self playOrPause:self.playOrPauseBtn];
}

- (void)destroyPlayer {
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.slider removeFromSuperview];
    self.slider = nil;
    [self removeFromSuperview];
}

- (void)playerBindTableView:(UITableView *)bindTableView currentIndexPath:(NSIndexPath *)currentIndexPath {
    self.bindTableView = bindTableView;
    self.currentIndexPath = currentIndexPath;
}

- (void)playerScrollIsSupportSmallWindowPlay:(BOOL)support {
    
    NSAssert(self.bindTableView != nil, @"必须绑定对应的tableview！！！");
    
    self.currentPlayCellRect = [self.bindTableView rectForRowAtIndexPath:self.currentIndexPath];
    self.currentIndexPath = self.currentIndexPath;
    
    CGFloat cellBottom = self.currentPlayCellRect.origin.y + self.currentPlayCellRect.size.height;
    CGFloat cellUp = self.currentPlayCellRect.origin.y;
    
    if (self.bindTableView.contentOffset.y > cellBottom) {
        if (!support) {
            [self destroyPlayer];
            return;
        }
        [self smallWindowPlay];
        return;
    }
    
    if (cellUp > self.bindTableView.contentOffset.y + self.bindTableView.frame.size.height) {
        if (!support) {
            [self destroyPlayer];
            return;
        }
        [self smallWindowPlay];
        return;
    }
    
    if (self.bindTableView.contentOffset.y < cellBottom){
        if (!support) return;
        [self returnToOriginView];
        return;
    }
    
    if (cellUp < self.bindTableView.contentOffset.y + self.bindTableView.frame.size.height){
        if (!support) return;
        [self returnToOriginView];
        return;
    }
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    
    if (!self.isOriginalFrame) {
        self.playerOriginalFrame = self.frame;
        self.playSuprView = self.superview;
        self.topBar.frame = CGRectMake(0, 0, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.bottomBar.frame = CGRectMake(0, self.playerOriginalFrame.size.height - bottomBaHeight, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.playerOriginalFrame.size.width - playBtnSideLength) / 2, (self.playerOriginalFrame.size.height - playBtnSideLength) / 2, playBtnSideLength, playBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
        self.isOriginalFrame = YES;
    }
}

#pragma mark - status hiden

- (void)setStatusBarHidden:(BOOL)hidden {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.hidden = hidden;
}

#pragma mark - NotificationCenter Observer

- (void)addNotificationCenterObserver {

    //screen orientation change && add the observer.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afNetworkingReachabilityDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)removeNotificationCenterObserver {

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

#pragma mark - Screen Orientation

- (void)statusBarOrientationChange:(NSNotification *)notification {
    if (self.smallWinPlaying) return;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        [self orientationLeftFullScreen];
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
        [self orientationRightFullScreen];
    }else if (orientation == UIDeviceOrientationPortrait) {
        [self smallScreen];
    }
}

- (void)actionClose {

    if(self.closeBlock) {self.closeBlock(self);}
}

- (void)actionFullScreen {
    if (!self.isFullScreen) {
        [self orientationLeftFullScreen];
    }else {
        [self smallScreen];
    }
}

- (void)orientationLeftFullScreen {
    self.isFullScreen = YES;
    self.zoomScreenBtn.selected = YES;
    [self.keyWindow addSubview:self];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.frame = self.keyWindow.bounds;
        self.topBar.hidden = YES;
        self.topBar.frame = CGRectMake(0, 0, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.bottomBar.frame = CGRectMake(0, self.keyWindow.bounds.size.width - bottomBaHeight, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.keyWindow.bounds.size.height - playBtnSideLength) / 2, (self.keyWindow.bounds.size.width - playBtnSideLength) / 2, playBtnSideLength, playBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.keyWindow.bounds.size.height / 2, self.keyWindow.bounds.size.width / 2);
    }];
    
    [self setStatusBarHidden:YES];
}

- (void)orientationRightFullScreen {
    self.isFullScreen = YES;
    self.zoomScreenBtn.selected = YES;
    [self.keyWindow addSubview:self];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.frame = self.keyWindow.bounds;
        self.topBar.hidden = YES;
        self.topBar.frame = CGRectMake(0, 0, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.bottomBar.frame = CGRectMake(0, self.keyWindow.bounds.size.width - bottomBaHeight, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.keyWindow.bounds.size.height - playBtnSideLength) / 2, (self.keyWindow.bounds.size.width - playBtnSideLength) / 2, playBtnSideLength, playBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.keyWindow.bounds.size.height / 2, self.keyWindow.bounds.size.width / 2);
    }];
    [self setStatusBarHidden:YES];
}

- (void)smallScreen {
    self.isFullScreen = NO;
    self.zoomScreenBtn.selected = NO;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
   
    if (self.bindTableView) {
        UITableViewCell *cell = [self.bindTableView cellForRowAtIndexPath:self.currentIndexPath];
        [cell.contentView addSubview:self];
    }
    else {
        [self.playSuprView addSubview:self];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.frame = self.playerOriginalFrame;
        self.topBar.hidden = NO;
        self.topBar.frame = CGRectMake(0, 0, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.bottomBar.frame = CGRectMake(0, self.playerOriginalFrame.size.height - bottomBaHeight, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.playerOriginalFrame.size.width - playBtnSideLength) / 2, (self.playerOriginalFrame.size.height - playBtnSideLength) / 2, playBtnSideLength, playBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
        [self updateConstraintsIfNeeded];
    }];
    [self setStatusBarHidden:NO];
}

#pragma mark - app notif

- (void)appDidEnterBackground:(NSNotification*)note {
    
    NSLog(@"appDidEnterBackground");
}

- (void)appWillEnterForeground:(NSNotification*)note {
    
    NSLog(@"appWillEnterForeground");
}

- (void)appwillResignActive:(NSNotification *)note {
    
    NSLog(@"appwillResignActive");
    
    _isPlayingBeforeResignActive = (_player.rate > 0.0);
    if(_isPlayingBeforeResignActive) {
        [self playOrPause:self.playOrPauseBtn];
    }
}

- (void)appBecomeActive:(NSNotification *)note {
    
    NSLog(@"appBecomeActive");
    
    if(_isPlayingBeforeResignActive) {
        [self playOrPause:self.playOrPauseBtn];
    }
}

- (BOOL)afNetworkingReachabilityDidChange:(NSNotification *)notification {
    
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if(self.player.rate == 1.0f && status == AFNetworkReachabilityStatusReachableViaWWAN
       && !self.isLocalFilePlay && !self.isPresentAlert) {
        
        self.playOrPauseBtn.selected = NO;
        self.isPresentAlert = YES;
        [self.player pause];
        [self showReachabilityStatusAlert];
        
        return YES;
    }
    return NO;
}

- (BOOL)afNetworkingReachabilityViaWWANAlert {
    
    BOOL isReachableViaWWAN = [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
    if(/*self.player.rate == 1.0f &&*/ isReachableViaWWAN
       && !self.isLocalFilePlay && !self.isPresentAlert) {
        
        self.playOrPauseBtn.selected = NO;
        self.isPresentAlert = YES;
        [self.player pause];
        [self showReachabilityStatusAlert];
        
        return YES;
    }
    return NO;
}

#pragma mark - alert dialog

- (void)showReachabilityStatusAlert {

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"您当前正在使用移动网络，继续播放将消耗流量" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"停止播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isPresentAlert = NO;
    }]];
    [vc addAction:[UIAlertAction actionWithTitle:@"继续播放" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.playOrPauseBtn.selected = YES;
        [self.player play];
        self.isPresentAlert = NO;
    }]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:^(void){}];
}

#pragma mark - button action

- (void)playOrPause:(UIButton *)btn {
    if(self.player.rate == 0.0){      //pause
        
        if([self afNetworkingReachabilityViaWWANAlert]) {
            ; //弹出正在使用移动网络，继续播放将消耗流量
        }
        else {
            btn.selected = YES;
            [self.player play];
        }
        
    }else if(self.player.rate == 1.0f){    //playing
        [self.player pause];
        btn.selected = NO;
    }
}

- (void)showOrHidenBar {
    if (self.barHiden) {
        [self show];
    }else {
        [self hiden];
    }
}

- (void)show {
    [UIView animateWithDuration:barAnimateSpeed animations:^{
        self.topBar.layer.opacity = opacity;
        self.bottomBar.layer.opacity = opacity;
        self.playOrPauseBtn.layer.opacity = opacity;
    } completion:^(BOOL finished) {
        if (finished) {
            self.barHiden = !self.barHiden;
            [self performBlock:^{
                if (!self.barHiden && !self.inOperation) {
                    [self hiden];
                }
            } afterDelay:barShowDuration];
        }
    }];
}

- (void)hiden {
    self.inOperation = NO;
    [UIView animateWithDuration:barAnimateSpeed animations:^{
        self.topBar.layer.opacity = 0.0f;
        self.bottomBar.layer.opacity = 0.0f;
        self.playOrPauseBtn.layer.opacity = 0.0f;
    } completion:^(BOOL finished){
        if (finished) {
            self.barHiden = !self.barHiden;
        }
    }];
}

#pragma mark - call back

- (void)sliderValueChange:(XLSlider *)slider {
    self.progressLabel.text = [self timeFormatted:slider.value * self.totalDuration];
}

- (void)finishChange {
    self.inOperation = NO;
    [self performBlock:^{
        if (!self.barHiden && !self.inOperation) {
            [self hiden];
        }
    } afterDelay:barShowDuration];
    
    [self.player pause];
    
    CMTime currentCMTime = CMTimeMake(self.slider.value * self.totalDuration, 1);
    if (self.slider.middleValue) {
        
        if(self.player.status != AVPlayerStatusReadyToPlay) return;
        [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
            [self.player play];
            self.playOrPauseBtn.selected = YES;
        }];
    }
}

//Dragging the thumb to suspend video playback

- (void)dragSlider {
    self.inOperation = YES;
    [self.player pause];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(callBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)callBlockAfterDelay:(void (^)(void))block {
    block();
}

#pragma mark - monitor PlayerItem （status，loadedTimeRanges）

- (void)addAVPlayerObserver {
    
    //get current playerItem object
    AVPlayerItem *playerItem = self.player.currentItem;
    __weak typeof(self) weakSelf = self;
    
    //Set once per second
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)  queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        weakSelf.current = current;
        float total = CMTimeGetSeconds([playerItem duration]);
        weakSelf.progressLabel.text = [weakSelf timeFormatted:current];
        if (current) {
//            NSLog(@"current --- %f", current );
            
            if (!weakSelf.inOperation) {
                 weakSelf.slider.value = current / total;
            }
            if (weakSelf.slider.value == 1.0f) {      //complete block
                if (weakSelf.completedPlayingBlock) {
                    [weakSelf setStatusBarHidden:NO];
                    if ( weakSelf.completedPlayingBlock) {
                        weakSelf.completedPlayingBlock(weakSelf);
                    }
                    weakSelf.completedPlayingBlock = nil;
                }else {       //finish and loop playback
                    weakSelf.playOrPauseBtn.selected = NO;
                    [weakSelf showOrHidenBar];
                    CMTime currentCMTime = CMTimeMake(0, 1);
                    [weakSelf.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
                        weakSelf.slider.value = 0.0f;
                    }];
                }
            }
        }
    }];
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //network loading progress
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeAVPlayerObserver {

    if(self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            self.totalDuration = CMTimeGetSeconds(playerItem.duration);
            self.totalDurationLabel.text = [self timeFormatted:self.totalDuration];
        }
        else if(status == AVPlayerStatusFailed) {
            
            NSLog(@"加载视频失败：-> %@",playerItem.error);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        self.slider.middleValue = totalBuffer / CMTimeGetSeconds(playerItem.duration);
//        NSLog(@"totalBuffer：%.2f",totalBuffer);
        
        //loading animation
        if (self.slider.middleValue  <= self.slider.value || (totalBuffer - 1.0) < self.current) {
            NSLog(@"正在缓冲...");
            self.activityIndicatorView.hidden = NO;
//            self.activityIndicatorView.center = self.center;
            [self.activityIndicatorView startAnimating];
        }else {
            self.activityIndicatorView.hidden = YES;
            if (self.playOrPauseBtn.selected) {
                [self.player play];
            }
        }
    }
}

#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

#pragma mark - animation smallWindowPlay

- (void)smallWindowPlay {
    if ([self.superview isKindOfClass:[UIWindow class]]) return;
    self.smallWinPlaying = YES;
    self.playOrPauseBtn.hidden = YES;
    self.bottomBar.hidden = YES;
    
    CGRect tableViewframe = [self.bindTableView convertRect:self.bindTableView.bounds toView:self.keyWindow];
    self.frame = [self convertRect:self.frame toView:self.keyWindow];
    [self.keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGFloat margin = 10.0;
        CGFloat w = self.playerOriginalFrame.size.width * 1/4;
        CGFloat h = w * 9/16.0;
        CGRect smallFrame = CGRectMake(tableViewframe.origin.x + tableViewframe.size.width - w - margin,
                                       tableViewframe.origin.y + tableViewframe.size.height - h - margin, w, h);
        self.frame = smallFrame;
        self.playerLayer.frame = self.bounds;
        self.activityIndicatorView.center = CGPointMake(w / 2.0, h / 2.0);
    }];
}

- (void)returnToOriginView {
    if (![self.superview isKindOfClass:[UIWindow class]]) return;
    self.smallWinPlaying = NO;
    self.playOrPauseBtn.hidden = NO;
    self.bottomBar.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.frame = CGRectMake(self.currentPlayCellRect.origin.x, self.currentPlayCellRect.origin.y, self.playerOriginalFrame.size.width, self.playerOriginalFrame.size.height);
        self.playerLayer.frame = self.bounds;
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
    } completion:^(BOOL finished) {
        self.frame = self.playerOriginalFrame;
        UITableViewCell *cell = [self.bindTableView cellForRowAtIndexPath:self.currentIndexPath];
        [cell.contentView addSubview:self];
    }];
}

#pragma mark - lazy loading

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    }
    return _playerLayer;
}

- (AVPlayer *)player{
    if (!_player) {
        // 解决8.1系统播放无声音问题，8.0、9.0以上未发现此问题
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];

        AVPlayerItem *playerItem = [self getAVPlayItem];
        self.playerItem = playerItem;
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        
        //add the player observer.
        [self addAVPlayerObserver];
    }
    return _player;
}

//initialize AVPlayerItem
- (AVPlayerItem *)getAVPlayItem{
    
    NSAssert(self.videoUrl != nil, @"必须先传入视频url！！！");
    
    if ([self.videoUrl rangeOfString:@"http"].location != NSNotFound) {
        NSString *url = [self.videoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        return playerItem;
    }else{
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.videoUrl] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        return playerItem;
    }
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self insertSubview:_activityIndicatorView aboveSubview:self.playOrPauseBtn];

    }
    return _activityIndicatorView;
}

- (UIView *)topBar {
    
    if(!_topBar) {
        
        CGFloat margin = 8.0;
        
        _topBar = [[UIView alloc] init];
        _topBar.backgroundColor = [UIColor clearColor];
        _topBar.layer.opacity = 0.0f;

        //返回或关闭
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = [UIColor clearColor];
        _closeBtn.hidden = self.closeHidden;
        [_closeBtn setImage:[UIImage imageNamed:@"XLVideoPlayer.bundle/close.png"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:_closeBtn];
        
        _closeBtn.sd_layout
        .topSpaceToView(_topBar, 0)
        .bottomSpaceToView(_topBar, 0)
        .leftSpaceToView(_topBar, margin)
        .widthIs(40.0);
    }
    return _topBar;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        
        CGFloat margin = 8.0;
        
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor clearColor];
        _bottomBar.layer.opacity = 0.0f;
        
        UIImageView *shadow = [[UIImageView alloc] init];
        shadow.contentMode = UIViewContentModeScaleAspectFill;
        shadow.clipsToBounds = YES;
        shadow.image = [UIImage imageNamed:@"XLVideoPlayer.bundle/bottom_shadow.png"];
        [_bottomBar addSubview:shadow];
        
        shadow.sd_layout
        .topSpaceToView(_bottomBar, 0)
        .bottomSpaceToView(_bottomBar, 0)
        .leftSpaceToView(_bottomBar, 0)
        .rightSpaceToView(_bottomBar, 0);

        //播放进度
        UILabel *label1 = [[UILabel alloc] init];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"00:00:00";
        label1.font = [UIFont systemFontOfSize:12.0f];
        label1.textColor = [UIColor whiteColor];
        [_bottomBar addSubview:label1];
        self.progressLabel = label1;
        
        label1.sd_layout
        .topSpaceToView(_bottomBar, 0)
        .bottomSpaceToView(_bottomBar, 0)
        .leftSpaceToView(_bottomBar, margin)
        .widthIs(65.0f);
        
        //全屏-半屏切换
        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fullScreenBtn.translatesAutoresizingMaskIntoConstraints = NO;
        fullScreenBtn.contentMode = UIViewContentModeCenter;
        [fullScreenBtn setImage:[UIImage imageNamed:@"XLVideoPlayer.bundle/shrink_screen.png"] forState:UIControlStateNormal];
        [fullScreenBtn setImage:[UIImage imageNamed:@"XLVideoPlayer.bundle/full_screen.png"] forState:UIControlStateSelected];
        [fullScreenBtn addTarget:self action:@selector(actionFullScreen) forControlEvents:UIControlEventTouchDown];
        [_bottomBar addSubview:fullScreenBtn];
        self.zoomScreenBtn = fullScreenBtn;
        
        fullScreenBtn.sd_layout
        .widthIs(40.0f)
        .heightIs(40.0f)
        .rightSpaceToView(_bottomBar, margin)
        .centerYEqualToView(_bottomBar);
        
        
        //总播放时长
        UILabel *label2 = [[UILabel alloc] init];
        label2.translatesAutoresizingMaskIntoConstraints = NO;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.text = @"00:00:00";
        label2.font = [UIFont systemFontOfSize:12.0f];
        label2.textColor = [UIColor whiteColor];
        [_bottomBar addSubview:label2];
        self.totalDurationLabel = label2;
        
        label2.sd_layout
        .topSpaceToView(_bottomBar, 0)
        .bottomSpaceToView(_bottomBar, 0)
        .rightSpaceToView(fullScreenBtn, margin)
        .widthIs(65.0f);
        
        
        //进度滑块
        XLSlider *slider = [[XLSlider alloc] init];
        slider.value = 0.0f;
        slider.middleValue = 0.0f;
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomBar addSubview:slider];
        self.slider = slider;
        __weak typeof(self) weakSelf = self;
        slider.valueChangeBlock = ^(XLSlider *slider){
            [weakSelf sliderValueChange:slider];
        };
        slider.finishChangeBlock = ^(XLSlider *slider){
            [weakSelf finishChange];
        };
        slider.draggingSliderBlock = ^(XLSlider *slider){
            [weakSelf dragSlider];
        };
        
        slider.sd_layout
        .topSpaceToView(_bottomBar, 0)
        .bottomSpaceToView(_bottomBar, 0)
        .leftSpaceToView(label1, margin)
        .rightSpaceToView(label2, margin);
    }
    return _bottomBar;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseBtn.layer.opacity = 0.0f;
        _playOrPauseBtn.contentMode = UIViewContentModeCenter;
        [_playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"XLVideoPlayer.bundle/play.png"] forState:UIControlStateNormal];
        [_playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"XLVideoPlayer.bundle/pause.png"] forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchDown];
    }
    return _playOrPauseBtn;
}

#pragma mark - dealloc

- (void)dealloc {
    
    //remove the player observer.
    [self removeAVPlayerObserver];

    //screen orientation change && remove the observer.
    [self removeNotificationCenterObserver];
    
    //dealloc log.
    NSLog(@"video player - dealloc");
}

@end
