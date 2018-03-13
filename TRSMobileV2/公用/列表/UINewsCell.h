//
//  UINewsCell.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/27.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

/**
 * 新闻的公用基类
 */
@interface UINewsCell : MGSwipeTableCell

/**
 * 图片
 */
@property (strong, nonatomic) UIImageView  *imagePic1;

/**
 * 标题
 */
@property (strong, nonatomic) UILabel   *labelTitle;

/**
 * 来源
 */
@property (strong, nonatomic) UILabel   *labelSource;

/**
 * 时间
 */
@property (strong, nonatomic) UILabel   *labelDate;

/**
 * 评论数
 */
@property (strong, nonatomic) UILabel   *labelComment;

/**
 *  第二张图片（如果有的话）
 */
@property (strong, nonatomic) UIImageView *imagePic2;

/**
 *  第三张图片（如果有的话）
 */
@property (strong, nonatomic) UIImageView *imagePic3;

/**
 *  底部分界线
 */
@property (strong, nonatomic) UIView     *viewLine;

@end


/**
 * 普通新闻
 */
@interface UINewsNormalCell : UINewsCell


@end

/**
 * 3张图片新闻
 */
@interface UINewsImagesCell : UINewsCell


@end

/**
 * 推荐大横图新闻
 */
@interface UINewsLargeImageCell : UINewsCell


@end


/**
 * 自定义图片新闻
 */
@interface UINewsPhotoCell : UINewsCell


@end


