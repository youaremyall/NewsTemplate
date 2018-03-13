//
//  UINewsSubscribleItem.h
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/19.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>

/*用户定制的新闻栏目*/
#define UserNewsChannel     @"user.news.channel"

/*栏目固定，不可删除和排序*/
#define isChannelFix        @"isFix"

/*栏目订阅标志*/
#define isChannelSubscrible @"isSubscrible"


@interface UINewsSubscribleItem : UIView

/*设备是否iPhone6以后*/
#define IsIphone6Later       ([[UIScreen mainScreen] currentMode].size.width > 640.0)

/*删除按钮*/
@property (readonly, strong, nonatomic) UIButton *buttonDelete;

/*显示栏目文字的按钮*/
@property (readonly, strong, nonatomic) UIButton *button;

/*属于已订阅还是未订阅标志(仅用于判断是点击哪部分)*/
@property (assign, nonatomic) BOOL isSubscrible;

/*编辑标志*/
@property (assign, nonatomic) BOOL isEdit;

/*圆角标识*/
@property (assign, nonatomic) BOOL isCorner;

/*传入参数*/
@property (strong, nonatomic) NSDictionary *dict;

@end
