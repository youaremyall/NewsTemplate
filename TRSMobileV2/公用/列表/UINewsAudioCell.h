//
//  UINewsAudioCell.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/7.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINewsAudioCell : UITableViewCell

/**
 * 图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *imagePic1;

/**
 * 播放时长
 */
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;

/**
 * 播放图标
 */
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;

/**
 * 标题
 */
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

/**
 * 来源
 */
@property (weak, nonatomic) IBOutlet UILabel *labelSource;

/**
 * 播放次数
 */
@property (weak, nonatomic) IBOutlet UILabel *labelPlayCount;

/**
 * 分割线
 */
@property (weak, nonatomic) IBOutlet UIView *viewLine;

@end
