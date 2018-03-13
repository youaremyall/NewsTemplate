//
//  UIImage+Extensions.m
//  TibetVoice
//
//  Created by TRS on 13-7-23.
//  Copyright (c) 2013年 TRS. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extensions)

static CGFloat edgeSizeFromCornerRadius(CGFloat cornerRadius) {
    return cornerRadius * 2 + 1;
}

+ (UIImage * _Nonnull)imageWithView:(UIView * _Nonnull)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color cornerRadius:(CGFloat)cornerRadius {
    
    CGFloat minEdgeSize = edgeSizeFromCornerRadius(cornerRadius);
    CGRect rect = CGRectMake(0, 0, minEdgeSize, minEdgeSize);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (UIImage * _Nonnull)circularImageWithColor:(UIColor * _Nonnull)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [color setStroke];
    [circle addClip];
    [circle fill];
    [circle stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage * _Nonnull)scaleImageWithSize:(CGSize)size {
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float w = 0.0f; float h = 0.0f;
    float or = width * 1.0 / height;
    float nr = size.width * 1.0 / size.height;
    if(or < nr) {
        w = size.width;
        h = w * height / width;
    } else {
        h = size.height;
        w = h * width / height;
    }
    
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, w, h)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage * _Nonnull)clipImageWithRect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage * _Nonnull)colorImage:(UIColor * _Nonnull)color {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage * _Nonnull)grayImage {
    
    int width = self.size.width;
    int height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    return image;
}

- (UIImage * _Nonnull)imageMergedOnImage:(UIImage * _Nonnull)image  withImages:(NSArray * _Nonnull)images withImagePoints:(NSArray * _Nonnull)points {
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    int i = 0;
    for(UIImage *img in images) {
        [img drawInRect:CGRectMake([((points[i])[0]) floatValue], [((points[i])[1]) floatValue], img.size.width, img.size.height)];
        ++i;
    }
    CGImageRef newImg = CGImageCreateWithImageInRect(UIGraphicsGetImageFromCurrentImageContext().CGImage, CGRectMake(0, 0, image.size.width, image.size.height));
    UIImage *image__ = [UIImage imageWithCGImage:newImg];
    UIGraphicsEndImageContext();
    CGImageRelease(newImg);
    
    return image__;
}

@end


@implementation UIImage (PHVideoPlayer)

+ (void)thumbnailImageWithVideoURL:(nonnull NSURL *)videoURL completion:(void (^_Nullable)(UIImage * _Nonnull image) )completion {
    
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)] ] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if(!error && result == AVAssetImageGeneratorSucceeded) {
            if(completion) {completion([UIImage imageWithCGImage:image]);}
        }
        [generator cancelAllCGImageGeneration];
    }];
}

@end

