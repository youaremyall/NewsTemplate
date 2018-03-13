//
//  MPMusicPlayer.m
//  TibetVoice
//
//  Created by TRS on 13-7-26.
//  Copyright (c) 2013年 TRS. All rights reserved.
//

#import "MPMusicPlayer.h"
#import "SDWebImageManager.h"
#import "NSNotification+Extension.h"

@interface UIApplication (UIApplication_RemoteControl)

@end

@implementation UIApplication (UIApplication_RemoteControl)

- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    [[MPMusicPlayer sharedPlayer] remoteControlReceivedWithEvent:receivedEvent];
}

@end

@interface MPMusicPlayer ()
{
    /*播放子线程*/
    dispatch_queue_t                _queuePlay;
    
    /*虚拟剪辑*/
    BOOL                            _isVirtualVideo;
    CGFloat                         _startTime;
    CGFloat                         _endTime;
}

//播放组件
@property (nonatomic, retain) AVPlayer *player;

//歌曲总数
@property (nonatomic, readonly) NSInteger   total;

//当前索引
@property (nonatomic, readonly) NSInteger   index;

/*此标识用于避免网络状态发生更改时，重复多次弹出节约流量提示*/
@property (nonatomic, assign) BOOL isPresentAlert;
@property (nonatomic, assign) BOOL isLocalFilePlay;

@end

@implementation MPMusicPlayer

#pragma mark - 初始化
+ (instancetype)sharedPlayer {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (NSString *)downloadPath {

    // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    /*创建自定义的网页数据缓存目录，避免缓存文件一大堆都放在/Library/Caches/目录下*/
    NSString *__cachesPath = [cachesPath stringByAppendingPathComponent:@"download/audio"];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:__cachesPath];
    if(!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:__cachesPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return __cachesPath;
}

- (id)init {
    
    if(self = [super init]) {
        
        _queuePlay = dispatch_queue_create("com.musicplayer.queue", NULL);
        _audios = [[NSMutableArray alloc] initWithCapacity:0];

        [self becomeFirstResponder];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self setAVAudioSession];
        [self addNotificationCenterObserver];
    }
    return self;
}

- (void)dealloc {
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [self removeNotificationCenterObserver];
    
    NSLog(@"music player - dealloc");
}

#pragma mark - 监听通知
//@监听注册
- (void)addNotificationCenterObserver {
    
    //监听AVAudioSession
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance] ];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avAudioSessionRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance] ];
    
    //监听AVPlayer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avPlayerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avPlayerItemFailedToPlayToEndTime:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    
    //监听网络变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(afNetworkingReachabilityDidChange:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
}

//@监听移除
- (void)removeNotificationCenterObserver {
    
    //移除监听AVAudioSession
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:[AVAudioSession sharedInstance] ];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:[AVAudioSession sharedInstance] ];
    
    //移除监听AVPlayer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
    
    //移除监听网络变化
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFNetworkingReachabilityDidChangeNotification
                                                  object:nil];
}

//@AVAudioSession会话中断处理
- (void)avAudioSessionInterruption:(NSNotification *)notification {
    
    AVAudioSessionInterruptionType  interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            break;

        case AVAudioSessionInterruptionTypeEnded:
        {
            AVAudioSessionInterruptionOptions options = [notification.userInfo[AVAudioSessionInterruptionOptionKey] integerValue];
            if(options == AVAudioSessionInterruptionOptionShouldResume) {
                [_player play]; //继续播放
            }
            break;
        }
        default:
            break;
    }
}

//@AVAudioSession会话线路改变处理
- (void)avAudioSessionRouteChange:(NSNotification *)notification {
    
    AVAudioSessionRouteChangeReason changeReason =  [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (changeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable: //新输出可用
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: //旧输出不可用
        {
            //获取上一线路描述信息和输出设备类型
            AVAudioSessionRouteDescription *routeDescription = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
            AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
            if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
                [_player pause];  //暂停播放
            }
            
            break;
        }
        default:
            break;
    }
}

//@AVPlayer播放监听处理
- (void)avPlayerItemDidPlayToEndTime:(NSNotification *)notification {
    
    //播放完毕自动播放下一首
    self.shouldInitPlayItem = YES;
    [self playNext];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didAVPlayerItemPlayToEndTime:)]) {
            [_delegate didAVPlayerItemPlayToEndTime:self];
        }
    });
}

//@AVPlayer播放监听处理
- (void)avPlayerItemFailedToPlayToEndTime:(NSNotification *)notification {
    
    //播放出错自动播放下一首
    self.shouldInitPlayItem = YES;
    [self playNext];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate  respondsToSelector:@selector(didAVPlayerItemFailedToPlayToEndTime:)]) {
            [_delegate didAVPlayerItemFailedToPlayToEndTime:self];
        }
    });
}

- (BOOL)afNetworkingReachabilityDidChange:(NSNotification *)notification {
    
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if(self.player.rate == 1.0f && status == AFNetworkReachabilityStatusReachableViaWWAN
       && !self.isLocalFilePlay && !self.isPresentAlert) {
        
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
        (!_player || self.shouldInitPlayItem ? [self setAVPlayerItem] : [_player play]);
        self.isPresentAlert = NO;
    }]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:^(void){}];
}

#pragma mark - 远程控制
//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

//远程事件处理
- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [_player pause];
                break;
                
            case UIEventSubtypeRemoteControlStop:
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [_player play];
                break;
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPrev];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNext];
                break;
                
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                [_player pause];
                break;
                
            case UIEventSubtypeRemoteControlEndSeekingBackward:
            case UIEventSubtypeRemoteControlEndSeekingForward:
                [self seekToTime:CMTimeMake(receivedEvent.timestamp, 1)];
                [_player play];
                break;
            default:
                break;
        }
    }
}

//锁屏封面
- (void)configNowPlayingInfoCenter {
    
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) { //IOS5.0以后进入
        
        NSMutableDictionary * nowPlayingInfo = [NSMutableDictionary dictionaryWithCapacity:0];
        
        //当前播放歌曲
        NSDictionary *music = self.currentPlayingMusic;
        
        //歌曲类型 - MPMediaItemPropertyMediaType
        [nowPlayingInfo setObject:[NSNumber numberWithInt:MPMediaTypeAnyAudio] forKey:MPMediaItemPropertyMediaType];

        //歌曲标题
        if(music[kMusicName])   [nowPlayingInfo setObject:music[kMusicName] forKey:MPMediaItemPropertyTitle];
        
        //歌曲作者
        if(music[kMusicArtist]) [nowPlayingInfo setObject:music[kMusicArtist] forKey:MPMediaItemPropertyArtist];

        //专辑标题
        if(music[kMusicAlbum])  [nowPlayingInfo setObject:music[kMusicAlbum] forKey:MPMediaItemPropertyAlbumTitle];
        
        //锁屏信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
        
        //锁屏插图
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:music[kMusicArtwork] ]
                                                                        options:SDWebImageDownloaderLowPriority
                                                                       progress:nil
                                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                                          if(!image) {image = [UIImage imageNamed:@"MPMusicPlayer.bundle/图片_锁屏.jpg"];}
                                                                          MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
                                                                          [nowPlayingInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
                                                                          [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
                                                                      }];
    }
}

- (void)updateNowPlayingInfoCenter {

    NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
    [nowPlayingInfo setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [nowPlayingInfo setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}

#pragma mark - 播放加载

//设置底层音频会话
- (void)setAVAudioSession {
    
    //设置音频会话类别
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(!success) {
        NSLog(@"AVAudioSession set category playback error :%@", error.localizedDescription);
        return;
    }
    
    //激活音频会话
    success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if(!success) {
        NSLog(@"AVAudioSession set active error :%@", error.localizedDescription);
        return;
    }
}

//设置播放项
- (void)setAVPlayerItem {
    
    /*预加载前的数据处理*/
    NSDictionary *music = self.currentPlayingMusic;

    //有效性检查
    NSString *url = music[kMusicUrl];
    if(!url || [url isKindOfClass:[NSNull class]] || url.length == 0 || [url isEqualToString:@""]) return;
    
    //判断直播或点播
    _isLive = [url.pathExtension isEqualToString:@"m3u8"];
    
    //判断本地播放或网络数据流?
    NSString *path = [[MPMusicPlayer downloadPath] stringByAppendingPathComponent:url.lastPathComponent ];
    BOOL isHTTPStream = (_isLive || ![[NSFileManager defaultManager] fileExistsAtPath:path]);
    if(isHTTPStream) {
        _isVirtualVideo = [music[@"isVirtualVideo"] boolValue];
        if(_isVirtualVideo) { //虚拟音频剪辑支持
            _startTime = [music[@"startTime"] floatValue];
            _endTime = [music[@"endTime"] floatValue];
        }
    }
    self.isLocalFilePlay = (isHTTPStream ? NO : YES); //本地文件播放?
    
    //正在预加载需要播放的资源
    NSURL * assetURL = (isHTTPStream ? [NSURL URLWithString:url] : [NSURL fileURLWithPath:path]);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    NSArray *tracksKeys = [NSArray arrayWithObjects:@"tracks", @"playable", nil];
    [asset loadValuesAsynchronouslyForKeys:tracksKeys
                         completionHandler:^(void) {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), _queuePlay, ^{
                                 [self prepareToPlayAsset:asset withKeys:tracksKeys];
                             });
                         }];
    
    //通知上层处理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(didAVPlayerItemChange:)]) {
            [_delegate didAVPlayerItemChange:self];
        }
    });
}

//播放
- (void)playAsset:(AVPlayerItem *)playerItem {
    
    if(_index < 0 || _index >= _total) return;
    
    //init the AVPlayer with AVPlayerItem.
    if(!_player) {
        _player = [[AVPlayer alloc] initWithPlayerItem:playerItem ];
    }
    else {
        [_player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    //add the observe
    void (^periodicTimeObserverBlock)(CMTime time) = ^(CMTime time) {
        
        //音频虚拟剪辑播放完成
        if(_isVirtualVideo && (self.currentTime == self.duration)) {[_player pause];}
        
        //通知上层处理
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if(UIApplicationStateBackground == [UIApplication sharedApplication].applicationState) {
                [self updateNowPlayingInfoCenter]; //更新锁屏信息
            }
            
            if(_delegate && [_delegate respondsToSelector:@selector(didAVPlayerItemTrackingTime:duration:)]) {
                [_delegate didAVPlayerItemTrackingTime:self.currentTime duration:self.duration];
            }
        });
    };
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                          queue:_queuePlay
                                     usingBlock:periodicTimeObserverBlock];
    
    [self addAVPlayerObserver];
    
    /*重置初始化播放项标识*/
    self.shouldInitPlayItem = NO;
}

//@预加载判断AVPlayerItem 可播放性
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestKeys {
    
    /* Make sure that the value of each key has loaded successfully. */
    for(NSString *key in requestKeys) {
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:key error:&error];
        if(status == AVKeyValueStatusFailed) {
            [self prepareToPlayAssetFail:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if(!asset.playable) {
        /* Generate an error describing the failure. */
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Item cannot be played", NSLocalizedDescriptionKey,
                                    @"The assets tracks were loaded, but could not be playable.", NSLocalizedFailureReasonErrorKey,
                                    nil];
        NSError *error = [NSError errorWithDomain:@"HTTP Live Stream Player" code:0 userInfo:dictionary];
        /* Display the error to the user. */
        [self prepareToPlayAssetFail:error];
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Remove the origin observe for the AVPlayer and AVPlayItem asset*/
    [self removeAVPlayerObserver];
    
    /* start play the AVPlayer item */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), _queuePlay, ^{
        [self playAsset:[AVPlayerItem playerItemWithAsset:asset] ];
    });
}

//@某项AVPlayerItem不能播放处理
- (void)prepareToPlayAssetFail:(NSError *)error {
    
    //跳过，播放下一个曲目
    [self playNext];
}

#pragma mark - KVO监听

- (void)addAVPlayerObserver {

    /* Observe the AVPlayer "currentItem" property to find out when any
     AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
     occur.*/
    [_player addObserver:self
              forKeyPath:@"currentItem"
                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                 context:nil];
    
    /* Observe the AVPlayer "rate" property to update the scrubber control. */
    [_player addObserver:self
              forKeyPath:@"rate"
                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                 context:nil];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [_player.currentItem addObserver:self
                          forKeyPath:@"status"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:nil];
    
    /* Observe the player item "loadedTimeRanges" key to determine when it is ready to play. */
    [_player.currentItem addObserver:self
                          forKeyPath:@"loadedTimeRanges"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
}

- (void)removeAVPlayerObserver {

    if(_player) {
        [_player removeObserver:self forKeyPath:@"currentItem" context:nil];
        [_player removeObserver:self forKeyPath:@"rate" context:nil];
    }
    
    if(_player && _player.currentItem) {
        [_player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
        [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    }
}

//@播放过程中KVO监听 rate播放速率、currentItem播放项切换、status播放状态更改、缓冲加载
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    /* AVPlayer "rate" property value observer. */
    if([keyPath isEqualToString:@"rate"]) {
        
        /*AVPlayer "rate" property value observer. */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_delegate && [_delegate respondsToSelector:@selector(didAVPlayerItemRateChange:)]) {
                [_delegate didAVPlayerItemRateChange:self];
            }
            postNotificationName(MPMusicPlayerIsPlayingChangeNotification, nil, nil);
        });
    }
    /* AVPlayer "currentItem" property observer. Called when the AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did occur. */
    else if([keyPath isEqualToString:@"currentItem"]) {
        
        /* Is the new player item null? */
        if([object isKindOfClass:[NSNull class]]) {
            //the level view should disable buttons.
        }
        else { /* Replacement of player currentItem has occurred */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self configNowPlayingInfoCenter];
            });
        }
    }
    /* AVPlayerItem "status" property value observer. */
    else if ([keyPath isEqualToString:@"status"] ) {
        
        AVPlayerItemStatus status = ((AVPlayerItem *)object).status;
        switch (status) {
                
            case AVPlayerItemStatusReadyToPlay:
                if(_isVirtualVideo) { //音频虚拟剪辑
                    [object setForwardPlaybackEndTime:CMTimeMake(_endTime, 1)];
                    [object seekToTime:CMTimeMake(_startTime, 1) completionHandler:^(BOOL finished) {
                    }];
                }
                
                if(!_isStopByUser) { //先判断用户是否暂停播放
                    [_player play]; //开始播放
                    postNotificationName(MPMusicPlayerIsPlayingChangeNotification, nil, nil);
                }
                break;
            case AVPlayerItemStatusFailed:
                [_player pause]; //暂停当前播放
                [self prepareToPlayAssetFail:[(AVPlayerItem *)object error] ];
                postNotificationName(MPMusicPlayerIsPlayingChangeNotification, nil, nil);
                break;
            default:
                break;
        }
    }
    /* AVPlayerItem "loaded time range" property value observer. */
    else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray *timeRanges = ((AVPlayerItem *)object).loadedTimeRanges;
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue]; //本次缓冲时间范围
        NSTimeInterval totalBuffer = (CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration));//缓冲总长度
        CGFloat percent = totalBuffer / CMTimeGetSeconds(((AVPlayerItem *)object).duration);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_delegate && [_delegate respondsToSelector:@selector(didAVPlayerItemLoadedTimeRange:)]) {
                [_delegate didAVPlayerItemLoadedTimeRange:percent ];
            }
        });
    }
    
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 播放控制

/**
 * 播放或暂停
 */
- (void)playPause {
    
    if(!_player || self.shouldInitPlayItem) {
        
        if([self afNetworkingReachabilityViaWWANAlert]) {
            ;//弹出正在使用移动网络，继续播放将消耗流量
        }
        else {
            [self setAVPlayerItem];
        }
    }
    else {
        if(self.isPlaying) {
            [_player pause];
        }
        else {
            
            if([self afNetworkingReachabilityViaWWANAlert]) {
                ;//弹出正在使用移动网络，继续播放将消耗流量
            }
            else {
                [_player play];
            }
        }
    }
}

/**
 * 播放上一曲
 */
- (void)playPrev {
    
    switch (_numberOfLoops) {
        case AVPlayerLoopAll:   //循环播放
            --_index;
            if(_index < 0) _index = _total - 1;
            break;
            
        case AVPlayerLoopRandom: //随机播放
            _index = arc4random() % _total;
            break;
            
        case AVPlayerLoopOnce: //单曲播放
            return;
            
        default:
            break;
    }
    [_player pause]; //停止当前播放
    [self setAVPlayerItem];
}


/**
 * 播放下一曲
 */
- (void)playNext {
    
    switch (_numberOfLoops) {
            
        case AVPlayerLoopAll:   //循环播放
            ++_index;
            if(_index > (_total - 1)) _index = 0;
            break;
            
        case AVPlayerLoopRandom: //随机播放
            _index = arc4random() % _total;
            break;
            
        case AVPlayerLoopOnce: //单曲播放
            return;
            
        default:
            break;
    }
    [_player pause]; //停止当前播放
    [self setAVPlayerItem];
}


/**
 * 播放定位
 */
- (void)seekToTime:(CMTime)time {
    
    if(_player.status != AVPlayerStatusReadyToPlay) return;
    
    if(_isVirtualVideo) { //音频虚拟剪辑
        time = CMTimeMake(_startTime + CMTimeGetSeconds(time), 1);
    }
    
    [_player seekToTime:time completionHandler:^(BOOL finished) {
        
    }];
}

/**
 * 当前播放时长
 */
- (NSTimeInterval)currentTime {
    
    if(_player == nil) return 0;
    
    CMTime currentTime = _player.currentItem.currentTime;
    if(CMTIME_IS_INVALID(currentTime)) return 0;
    
    double currentTime_ = CMTimeGetSeconds(currentTime);
    if (isfinite(currentTime_)) {
        return (_isVirtualVideo ? (currentTime_ - _startTime) : currentTime_);
    }
    
    return 0;
}

/**
 * 歌曲时长
 */
- (NSTimeInterval)duration {
    
    if(_player == nil) return 0;
    
    CMTime durationTime = _player.currentItem.duration;
    if(CMTIME_IS_INVALID(durationTime)) return 0;
    
    double durationTime_ = CMTimeGetSeconds(durationTime);
    if(isfinite(durationTime_)) {
        return (_isVirtualVideo ? (_endTime - _startTime) : durationTime_);
    }
    
    return 0;
}

/**
 * 播放状态
 */
- (BOOL)isPlaying {
    
    return (_player.rate > 0.0 ? YES : NO);
}

#pragma mark - 数据相关

/**
 * 设置音乐数据
 */
- (void)setPlayItems:(NSArray *)items {
    
    [_player pause]; //停止当前播放
    
    [_audios removeAllObjects];
    [_audios addObjectsFromArray:items];
    
    _index = 0; //重置索引和参数
    _total = _audios.count;
}

/**
 * 播放指定索引的歌曲
 */
- (void)playItemAtIndex:(NSInteger)index {
    
    //有效性检查
    if(index < 0 || index >= _total) return;
    
    _index = index;
    
    [_player pause]; //停止当前播放
    [self setAVPlayerItem];
}

/**
 * 当前歌曲信息
 */
- (NSDictionary *)currentPlayingMusic {

    return (_index < _audios.count ? _audios[_index] : nil);
}

@end
