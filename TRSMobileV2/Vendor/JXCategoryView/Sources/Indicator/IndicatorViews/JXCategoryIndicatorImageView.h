//
//  JXCategoryIndicatorImageView.h
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/17.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "JXCategoryIndicatorComponentView.h"

@interface JXCategoryIndicatorImageView : JXCategoryIndicatorComponentView
//显示指示器图片的UIImageView
@property (nonatomic, strong, readonly) UIImageView *indicatorImageView;
//图片是否开启滚动。默认NO
@property (nonatomic, assign) BOOL indicatorImageViewRollEnabled;
//图片的尺寸。默认：CGSizeMake(30, 20)
@property (nonatomic, assign) CGSize indicatorImageViewSize;

@end
