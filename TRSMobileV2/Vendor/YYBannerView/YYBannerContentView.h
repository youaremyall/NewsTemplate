//
//  YYBannerContentView.h
//  ProductSammary
//
//  Created by yuans on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYBannerContentView;

typedef void(^YYBannerContentViewBlock)(YYBannerContentView * sender);

@interface YYBannerContentView : UIView

@property (nonatomic,copy)YYBannerContentViewBlock callBack;

- (void)setUserInteraction:(BOOL)enable;

- (void)setContentIMGWithStr:(NSString *)str palceHolder:(UIImage *)image;

- (void)setOffsetWithFactor:(float)value; //偏移的百分比


-(instancetype)init NS_UNAVAILABLE;
-(instancetype)new NS_UNAVAILABLE;

@end
