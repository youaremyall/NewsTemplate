//
//  UIImage+QRCode.h
//  TRSMobileV2
//
//  Created by  TRS on 16/7/5.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface  UIImage (UIImage_QRCode)

/**
 * 对图片不失真地缩放
 */
+ (UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size;

/**
 * 更改图片背景颜色
 */
+ (UIImage *)specialColorImage:(UIImage*)image withRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
