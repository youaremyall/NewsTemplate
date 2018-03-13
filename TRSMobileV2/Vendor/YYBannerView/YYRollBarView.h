//
//  YYRollBarView.h
//  ProductSammary
//
//  Created by admin on 16/11/17.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^YYRollBarCallBlock)(NSString * model,int index);

@protocol YYBarViewDelegate;

@interface YYRollBarView : UIView

@property (nonatomic, assign)id<YYBarViewDelegate> delegate;
@property (nonatomic, assign)BOOL autoScroll; //timer default:YES
@property (nonatomic,assign) NSTimeInterval  timerInterval; //default:3s
@property (nonatomic,copy)YYRollBarCallBlock callBack;
-(void)setDataWithArray:(NSArray<NSString *> *)dataAyy ;

-(instancetype)init NS_UNAVAILABLE;
@end

@protocol YYBarViewDelegate <NSObject>

- (void)YYBannerView:(YYRollBarView *)view bannerModel:(NSString *)model index:(int )index;

@end
NS_ASSUME_NONNULL_END
