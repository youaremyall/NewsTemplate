//
//  iVersion.m
//  MobileEditing
//
//  Created by  TRS on 2017/5/10.
//  Copyright © 2017年 trs. All rights reserved.
//

#import "iVersion+Provider.h"
#import "iVersionView.h"

#if DEBUG
#import <PgyUpdate/PgyUpdateManager.h>
#import "NSDictionary+Extension.h"
#else
#import "AFHTTP+Provider.h"
#import "NSDate+Extension.h"
#import "NSString+Extension.h"
#endif

@interface iVersion  ()

@property (assign, nonatomic) BOOL isLaunch;

@end

@implementation iVersion

+ (void)load {
    
#if DEBUG
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:valueForDictionaryFile(@"Vendor")[@"PgyerAppId"]];
#endif
    [self performSelector:@selector(checkVersion:) withObject:@(YES) afterDelay:1.0]; //检测最新版本
}

+ (void)checkVersion:(NSNumber *)isLaunch {
    
    iVersion *version = [[iVersion alloc] init];
    version.isLaunch = isLaunch.boolValue;
    [version checkVersion];
}

- (void)checkVersion {
    
#if DEBUG
    [[PgyUpdateManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(checkUpdateResult:)];
#else
    
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/CN/lookup?bundleId=%@", [NSBundle mainBundle].bundleIdentifier ];
    [AFHTTP request:url completion:^(BOOL success, id _Nullable response, NSError * _Nullable error) {
        
        if(success && [response isKindOfClass:[NSDictionary class]]) {
            
            NSArray *results = response[@"results"];
            if(results.count) {
                [self checkUpdateResult:results[0] ];
            }
        }
    }];
#endif
}

- (void)checkUpdateResult:(NSDictionary *)response {
    
    NSString * localVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
#if DEBUG
    NSString * localBuild = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
    if(response &&
       ([response[@"versionName"] compare:localVersion] == NSOrderedDescending
        || [response[@"versionCode"] compare:localBuild] == NSOrderedDescending)) {
           
           [iVersionView showWithVersion:response[@"versionName"] releaseTime:nil releaseNotes:response[@"releaseNote"] releaseUrl:response[@"downloadURL"] isForceUpdate:NO];
       }
#else
    if(response &&
       ([response[@"version"] compare:localVersion] == NSOrderedDescending)) {
        
        //当前系统时间
        NSString *_now = [NSDate dateStringByDate:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"];
        
        //应用更新时间
        NSDate *_releaseUTC = [NSDate dateByDateString:response[@"currentVersionReleaseDate"] format:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString *_releaseDate = [NSDate dateStringByDate:_releaseUTC format:@"yyyy-MM-dd HH:mm:ss"];
        BOOL isLater = ([_now compare:_releaseDate] == NSOrderedDescending);
        
        if(isLater) {
            
            NSString *releaseTime = [_releaseDate substringToIndex:10];
            [iVersionView showWithVersion:response[@"version"] releaseTime:releaseTime releaseNotes:response[@"releaseNotes"] releaseUrl:response[@"trackViewUrl"] isForceUpdate:NO];
            
        }
    }
#endif
    else if(!_isLaunch) {
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"版本更新" message:@"恭喜您，已是最新版本！" preferredStyle:(UIAlertControllerStyleAlert)];
        [vc addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:^{
        }];
    }
}

@end
