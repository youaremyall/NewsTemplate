//
//  UIImage+Extensions.h
//  TibetVoice
//
//  Created by TRS on 13-7-23.
//  Copyright (c) 2013年 TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

/**
 * @brief  由视图创建图片
 * @param  view 	视图对象
 * @return 图片对象
 */
+ (UIImage * _Nonnull)imageWithView:(UIView * _Nonnull)view;

/**
 * @brief  由颜色值获取图片
 * @param  color        颜色值
 * @param  cornerRadius 圆角半径
 * @return
 */
+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color cornerRadius:(CGFloat)cornerRadius;

/**
 * @brief  由颜色值半径大小获取圆形图片
 * @param  color 颜色值
 * @param  size
 * @return
 */
+ (UIImage * _Nonnull)circularImageWithColor:(UIColor * _Nonnull)color size:(CGSize)size;


/**
 * @brief  等比缩放照片
 * @param  size 	缩放的图片尺寸。如果该尺寸不是按照等比设置，则函数按照宽度或高度最大比例进行等比缩放。
 * @return 等比缩放后的图片对象
 */
- (UIImage * _Nonnull)scaleImageWithSize:(CGSize)size;

/**
 * @brief  裁剪图片
 * @param  rect 	裁剪范围
 * @return 裁剪后的图片对象
 */
- (UIImage * _Nonnull)clipImageWithRect:(CGRect)rect;

/**
 * @brief  改变图片颜色
 * @param  color        颜色值
 * @return
 */
- (UIImage * _Nonnull)colorImage:(UIColor *_Nonnull)color;

/**
 * @brief  获取灰度化图片
 *@return  灰度化图片
 */
- (UIImage * _Nonnull)grayImage;

/**
 * @brief  图片合成
 * @param  image  待合成的主图片
 * @param  images 合成图片
 * @param  points 合成图片的起始位置，points的对象为CGPoint对象取值的数组
 *  @retuen 合成后的新图片
 */
- (UIImage * _Nonnull)imageMergedOnImage:(UIImage * _Nonnull)image  withImages:(NSArray * _Nonnull)images withImagePoints:(NSArray *_Nonnull)points;

@end


#import <Photos/Photos.h>
@interface UIImage (PHVideoPlayer)

/**
 * 获取本地视频的略缩图
 */
+ (void)thumbnailImageWithVideoURL:(nonnull NSURL *)videoURL completion:(void (^_Nullable)(UIImage * _Nonnull image) )completion;

@end

