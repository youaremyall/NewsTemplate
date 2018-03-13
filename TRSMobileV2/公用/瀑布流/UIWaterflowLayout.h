//
//  UIWaterflowLayout.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/28.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol UIWaterflowLayoutDelegate;
@interface UIWaterflowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<UIWaterflowLayoutDelegate> delegate;

@end

@protocol UIWaterflowLayoutDelegate <NSObject>

@required

/**瀑布流对于cell为index所对应的高度*/
- (CGFloat)waterflowLayout:(UIWaterflowLayout *)layout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;

@optional

/**瀑布流的列数*/
- (NSInteger)columnCountInWaterflowLayout:(UIWaterflowLayout *)layout;

/**每一列之间的间距*/
- (CGFloat)minimumInteritemSpacingInWaterflowLayout:(UIWaterflowLayout *)layout;

/**每一行之间的间距*/
- (CGFloat)minimumLineSpacingInWaterflowLayout:(UIWaterflowLayout *)layout;

/**cell边缘的间距*/
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(UIWaterflowLayout *)layout;

/**每一个section的头部header**/
- (CGSize)sizeForHeaderInWaterflowLayout:(UIWaterflowLayout *)layout;

@end
