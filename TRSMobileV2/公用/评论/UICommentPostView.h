//
//  UICommentPostView.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Extension.h"

UIKIT_EXTERN NSString *_Nonnull const didCommentPostNotification;

typedef NS_ENUM(NSInteger, commentPolicy) {
    commentPolicyNone = 0,      //禁止评论
    commentPolicyReviewFirst,   //允许评论，先审后发
    commentPolicySendFirst,     //允许评论，先发后审
};

typedef NS_ENUM(NSInteger, commentStatus) {
    commentStatusYes = 0,       //审核已通过
    commentStatusReview,        //待审核中，对应先审后发
    commentStatusYesPre,        //审核预通过，对应先发后审
};

@interface UICommentPostView : UIView

/**
 * 事件处理回调
 */
@property (copy, nonatomic) void (^_Nullable dismissBlock)(void);

/**
 * 当前文章数据
 */
@property (strong, nonatomic) NSDictionary  * _Nonnull dict;

/**
 * 细览类型，用于发表评论
 */
@property (assign, nonatomic) clickType  type;

/**
 * 评论发表策略
 */
@property (assign, nonatomic) commentPolicy commentPolicy;

/**
 * 最大字符个数
 */
@property (assign, nonatomic) NSInteger  maxLimit;

@end
