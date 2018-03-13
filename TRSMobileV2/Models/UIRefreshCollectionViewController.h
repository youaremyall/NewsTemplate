//
//  UIRefreshCollectionViewController.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWaterflowLayout.h"
#import "MJRefresh.h"

@class UICycleScrollView;
@interface UIRefreshCollectionViewController : UICollectionViewController

/**
 * 请求事件回调
 */
@property (copy, nonatomic) void (^_Nullable requestBlock)(void);

/**
 * 请求地址回调
 */
@property (copy, nonatomic) NSString * _Nonnull (^ _Nullable urlBlock)(void);

/**
 * 响应数据回调
 */
@property (copy, nonatomic) void (^ _Nullable responseBlock)(BOOL success, id _Nonnull response);

/**
 * 顶部推荐滚动大图
 */
@property (strong, nonatomic) UICycleScrollView  * _Nonnull csView;

/**
 * 顶部推荐数据
 */
@property (strong, nonatomic) NSMutableArray * _Nonnull ads;

/**
 * 中间列表数据
 */
@property (strong, nonatomic) NSMutableArray * _Nonnull datasource;

/**
 * 当前页数
 */
@property (assign, nonatomic) NSInteger pageIndex;

/**
 * 总页数
 */
@property (assign, nonatomic) NSInteger pageTotal;

/**
 * 下拉刷新标识
 */
@property (assign, nonatomic) BOOL hasRefreshHeader;

/**
 * 上拉加载更多标识
 */
@property (assign, nonatomic) BOOL hasRefreshFooter;

/**
 * 是否刷新标识
 */
@property (assign, nonatomic) BOOL isRefresh;

@end
