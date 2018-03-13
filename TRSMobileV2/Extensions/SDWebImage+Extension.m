//
//  SDWebImage+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/15.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "SDWebImage+Extension.h"
#import "UIImageView+HighlightedWebCache.h"
#import "AFHTTP+Provider.h"
#import "NSUserDefaults+Extension.h"

@implementation UIImageView (Extension)

- (void)setUIImageWithURL:(NSString * _Nonnull)url
         placeholderImage:(UIImage * _Nullable)placeholder
                completed:(SDExternalCompletionBlock _Nullable)completionBlock {
    
    [self setUIImageWithURL:url
           placeholderImage:placeholder
                   progress:nil
                  completed:completionBlock];
}

- (void)setUIImageWithURL:(NSString * _Nonnull)url
         placeholderImage:(UIImage * _Nullable)placeholder
                 progress:(SDWebImageDownloaderProgressBlock _Nullable)progressBlock
                completed:(SDExternalCompletionBlock _Nullable)completionBlock {
    
    if([url rangeOfString:@"file://"].location != NSNotFound
       && [url rangeOfString:@"http://"].location == NSNotFound) {
        
        NSRange range = [url rangeOfString:@"file://"];
        if(range.location != NSNotFound) {
            url = [url substringFromIndex:(range.location + range.length)];
        }
        if(url.length)
            self.image = [UIImage imageNamed:url];
        else
            self.image = placeholder;
    }
    else {
        SDExternalCompletionBlock block = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if(!image || error) {
                NSRange range = [url rangeOfString:@"_"]; //解析URL地址，获得图片原地址
                if(range.location != NSNotFound) {
                    NSString *url_origin = [NSString stringWithFormat:@"%@.%@", [url substringToIndex:range.location], [url pathExtension] ];
                    [self sd_setImageWithURL:[NSURL URLWithString:url_origin]
                            placeholderImage:placeholder
                                     options:0
                                    progress:progressBlock
                                   completed:completionBlock];
                }
            }
            else if(completionBlock) {
                {completionBlock(image, error, cacheType, imageURL);}
            }
        };
        
        BOOL isOnlyWiFi = [[NSUserDefaults settingValueForType:SettingTypeOnlyWiFiLoadImages] boolValue];
        BOOL isWWAN = (statusAFNetworkReachability == AFNetworkReachabilityStatusReachableViaWWAN);
        if(isWWAN && isOnlyWiFi) {
            self.image = placeholder;
            return;
        }
        
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:0 progress:nil completed:block];
    }
}

@end
