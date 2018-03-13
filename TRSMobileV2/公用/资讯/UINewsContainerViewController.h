//
//  UINewsContainerViewController.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/22.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINewsContainerViewController : UICollectionViewController


/**
 * 新闻栏目频道数据
 */
@property (strong, nonatomic) NSArray * _Nonnull channels;

/**
 * 过滤栏目标识，默认为YES : 仅加载已订阅的新闻栏目， NO:加载所有栏目
 */
@property (assign, nonatomic) BOOL   isFliter;

/**
 * 容器滚动事件回调
 */
@property (copy, nonatomic) void (^ _Nullable changeEvent)(NSDictionary * _Nonnull channel, NSInteger index);

/**
 * 设置当前索引.
 */
- (void)setIndex:(NSInteger)index;


@end
