//
//  MPDefines.h
//  TibetQS
//
//  Created by  TRS on 15/12/21.
//  Copyright © 2015年 TRS. All rights reserved.
//

#ifndef MPDefines_h
#define MPDefines_h

//所属专辑
#define kMusicAlbum         @"album"

//歌曲标题
#define kMusicName			@"title"

//艺术家
#define kMusicArtist        @"singer"

//歌曲插图
#define kMusicArtwork		@"image"

//播放地址
#define kMusicUrl			@"media"

//歌词地址
#define kMusicLyric			@"lrc"

//播放状态更改通知
#define MPMusicPlayerIsPlayingChangeNotification   @"musicplayer.isPlaying.change"

//循环模式
typedef NS_ENUM(NSInteger, AVPlayerLoop){
    AVPlayerLoopAll = 0x00,         //循环播放
    AVPlayerLoopSingle,             //单曲循环
    AVPlayerLoopRandom,             //随机播放
    AVPlayerLoopOnce                //单曲播放
};

#endif /* MPDefines_h */
