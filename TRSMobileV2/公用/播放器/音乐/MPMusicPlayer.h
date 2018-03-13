//
//  MPMusicPlayer.h
//  TibetVoice
//
//  Created by TRS on 13-7-26.
//  Copyright (c) 2013年 TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworkReachabilityManager.h"
#import "MPDefines.h"

@protocol MPMusicPlayerDelegate;
@interface MPMusicPlayer : UIResponder

/**
 * 托管协议
 */
@property (nonatomic, weak) id <MPMusicPlayerDelegate> delegate;

/**
 * 循环模式
 */
@property (nonatomic, assign) AVPlayerLoop  numberOfLoops;

/**
 *歌曲队列
 */
@property (nonatomic, retain, readonly) NSMutableArray  *audios;

/**
 * 歌曲时长
 */
@property (nonatomic, readonly) NSTimeInterval  duration;

/**
 * 直播标志
 */
@property (nonatomic, readonly) BOOL    isLive;

/**
 * 播发状态
 */
@property (nonatomic, readonly) BOOL    isPlaying;

/*
 *初始化播放项
 */
@property (nonatomic, assign) BOOL      shouldInitPlayItem;

/*
 * 用户停止播放
 */
@property (nonatomic, assign) BOOL      isStopByUser;

#pragma mark -

/**
 * 全局对象
 */
+ (instancetype)sharedPlayer;


/**
 * 下载路径
 */
+ (NSString *)downloadPath;

#pragma mark - 播放控制

/**
 * 播放暂停
 */
- (void)playPause;

/**
 * 播放上一首
 */
- (void)playPrev;

/**
 * 播放下一首
 */
- (void)playNext;

/**
 * 播放定位
 */
- (void)seekToTime:(CMTime)time;


#pragma mark - 数据操作

/**
 * 设置音乐数据
 */
- (void)setPlayItems:(NSArray *)items;

/**
 * 播放指定索引的歌曲
 */
- (void)playItemAtIndex:(NSInteger)index;

/**
 * 当前歌曲信息
 */
- (NSDictionary *)currentPlayingMusic;

@end



@protocol MPMusicPlayerDelegate <NSObject>

@required

/**
 * 播放歌曲已切换
 */
- (void)didAVPlayerItemChange:(MPMusicPlayer *)player;

/**
 * 播放进度更新
 */
- (void)didAVPlayerItemTrackingTime:(float)currentTime duration:(float)duration;

/**
 * 缓冲进度更新
 */
- (void)didAVPlayerItemLoadedTimeRange:(float)progress;

@optional

/**
 * 播放状态更改
 */
- (void)didAVPlayerItemRateChange:(MPMusicPlayer *)player;

/**
 * 播放完成
 */
- (void)didAVPlayerItemPlayToEndTime:(MPMusicPlayer *)player;

/**
 * 播放失败
 */
- (void)didAVPlayerItemFailedToPlayToEndTime:(MPMusicPlayer *)player;

@end

