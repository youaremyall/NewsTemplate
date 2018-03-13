//
//  UICommentViewController.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBaseViewController.h"

@interface UICommentViewController : UIBaseViewController

/**
 * 总的评论数
 */
@property (assign, nonatomic) NSInteger     total;

/**
 * 我的评论标志
 */
@property (assign, nonatomic) BOOL          isMyComment;

@end
