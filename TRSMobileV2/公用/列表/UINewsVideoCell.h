//
//  UINewsAudioCell.h
//  TRSMobileV2
//
//  Created by  TRS on 16/5/24.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINewsVideoCell : UITableViewCell

/**
 * 图片
 */
@property (strong, nonatomic) IBOutlet UIImageView  *imagePic1;

/**
 * 标题
 */
@property (strong, nonatomic) IBOutlet UILabel  *labelTitle;

/**
 * 播放图标
 */
@property (strong, nonatomic) IBOutlet UIButton  *buttonPlay;

/**
 * 底部工具栏
 */
@property (strong, nonatomic) IBOutlet UIView    *viewToolbar;

/**
 * 评论图标
 */
@property (strong, nonatomic) IBOutlet UIButton  *buttonComment;

/**
 * 分享图标
 */
@property (strong, nonatomic) IBOutlet UIButton  *buttonShare;

/**
 * 来源图标
 */
@property (strong, nonatomic) IBOutlet UIImageView   *imageSource;

/**
 * 来源图标 (若没有，则以来源的第一个字显示)
 */
@property (strong, nonatomic) IBOutlet UILabel   *labelSource1;

/**
 * 来源
 */
@property (strong, nonatomic) IBOutlet UILabel   *labelSource;


/**
 * 播放次数
 */
@property (strong, nonatomic) IBOutlet UILabel   *labelPlayCount;

/**
 * 播放时长
 */
@property (strong, nonatomic) IBOutlet UILabel   *labelDuration;

@end
