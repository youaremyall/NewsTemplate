//
//  UIToolBar.h
//  TRSMobileV2
//
//  Created by  TRS on 16/5/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Extension.h"
#import "UICommentPostView.h"

UIKIT_EXTERN CGFloat kHeightUIToolbar;
UIKIT_EXTERN NSString *_Nonnull const didFavoriteChangeNotification;

@interface UIToolbarView : UIView

/**
 * 所属的视图控制器，用于发表评论和其它如收藏点赞操作
 */
@property (assign, nonatomic) UIViewController* _Nullable vc;

/**
 * 细览类型，用于添加收藏
 */
@property (assign, nonatomic) clickType  type;

/**
 * 评论发表策略
 */
@property (assign, nonatomic) commentPolicy commentPolicy;

/**
 * 仅显示发表评论
 */
@property (assign, nonatomic) BOOL onlyHasPost;

/**
 * 加载评论收藏状态
 */
- (void)loadProperty;

@end
