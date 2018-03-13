//
//  UIMyMessageCell.h
//  TRSMobileV2
//
//  Created by  TRS on 16/6/30.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMyMessageCell : UITableViewCell

/**
 * 已读，未读图标
 */
@property (strong, nonatomic) UIImageView   *imagePic1;

/**
 * 消息类型
 */
@property (strong, nonatomic) UILabel       *labelType;

/**
 * 消息内容
 */
@property (strong, nonatomic) UILabel       *labelContent;

/**
 * 消息类型
 */
@property (strong, nonatomic) UILabel       *labelDate;

/**
 * 分割线
 */
@property (strong, nonatomic) UIView        *viewLine;

@end
