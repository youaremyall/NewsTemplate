//
//  UIImage+QRCode.m
//  TRSMobileV2
//
//  Created by  TRS on 16/7/5.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIImage+QRCode.h"

@implementation UIImage (UIImage_QRCode)

void ProviderReleaseData (void *info, const void *data, size_t size) {
    free((void*)data);
}

+ (UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size {

    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();

    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);

    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);

    //Release
    CFRelease(colorSpaceRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);

    UIImage *__image = [UIImage imageWithCGImage:imageRefResized];
    CGImageRelease(imageRefResized);
    
    return __image;
}

+ (UIImage *)specialColorImage:(UIImage*)image withRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {

    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);

    //Create context
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);

    //Traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
         if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
                 //Change color
                 uint8_t* ptr = (uint8_t*)pCurPtr;
                 ptr[3] = red; //0~255
                 ptr[2] = green;
                 ptr[1] = blue;
             }else{
                     uint8_t* ptr = (uint8_t*)pCurPtr;
                     ptr[0] = 0;
                 }
     }

    //Convert to image
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                                                                kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProviderRef,
                                                                                NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProviderRef);
    
    UIImage* img = [UIImage imageWithCGImage:imageRef];

    //Release
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    return img;
}

@end
