//
//  UICommentCell.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICommentCell : UITableViewCell

/**
 * 头像
 */
@property (strong, nonatomic) UIImageView   *imagePic1;

/**
 * 昵称
 */
@property (strong, nonatomic) UILabel       *labelNick;

/**
 * 时间
 */
@property (strong, nonatomic) UILabel       *labelDate;

/**
 * 内容
 */
@property (strong, nonatomic) UILabel       *labelContent;


/**
 * 点赞
 */
@property (strong, nonatomic) UIButton       *buttonLike;


/**
 * 原文扩展背景(我的评论)
 */
@property (strong, nonatomic) UIView        *viewExtension;

/**
 * 原文扩展配图(我的评论)
 */
@property (strong, nonatomic) UIImageView   *imagePic2;

/**
 * 原文扩展标题(我的评论)
 */
@property (strong, nonatomic) UILabel       *labelTitle;

/**
 * 分割线
 */
@property (strong, nonatomic) UIView        *viewLine;


/**
 * 评论数据对象
 */
@property (strong, nonatomic) id            avObject;


/**
 * 我的评论标志
 */
@property (assign, nonatomic) BOOL          isMyComment;


@end
