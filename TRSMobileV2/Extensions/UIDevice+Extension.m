//
//  UIDevice+Extension.m
//  UFun
//
//  Created by wujianjun on 11-7-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIDevice+Extension.h"

bool isSimulator() {
    
    return (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location);
}

bool isiPad() {

    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

float screenWidth() {

    return [UIScreen mainScreen].bounds.size.width;
}

float screenHeight() {

    return [UIScreen mainScreen].bounds.size.height;
}

float deviceVersion() {

    return [UIDevice currentDevice].systemVersion.floatValue;
}

NSString * _Nonnull getDeviceId() {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleIdentifier"];
    NSString *deviceId = [SAMKeychain passwordForService:bundleIdentifier account:kSAMKeychainAccountKey];
    if(!deviceId) {
        deviceId = [[UIDevice currentDevice].identifierForVendor.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSError *error = nil;
        BOOL result = [SAMKeychain setPassword:deviceId forService:bundleIdentifier account:kSAMKeychainAccountKey error:&error];
        if(!result) {
            NSLog(@"存储钥匙串出错->%@", error.localizedDescription);
        }
    }
    return deviceId;
}

NSString * _Nonnull launchImage() {

    if([UIScreen instancesRespondToSelector:@selector(currentMode)]
       && CGSizeEqualToSize(CGSizeMake(1536,2048), [[UIScreen mainScreen] currentMode].size) ) {
        return @"Brand Assets-700-Portrait@2x~ipad.png";
    }
    else if([UIScreen instancesRespondToSelector:@selector(currentMode)]
            && CGSizeEqualToSize(CGSizeMake(768,1024), [[UIScreen mainScreen] currentMode].size) ) {
        return @"Brand Assets-700-Portrait@ipad.png";
    }
    else if([UIScreen instancesRespondToSelector:@selector(currentMode)]
       && CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) ) {
        return @"Brand Assets-800-Portrait-736h@3x.png";
    }
    else if([UIScreen instancesRespondToSelector:@selector(currentMode)]
            && CGSizeEqualToSize(CGSizeMake(750,1334), [[UIScreen mainScreen] currentMode].size) ) {
        return @"Brand Assets-800-667h@2x.png";
    }
    else if([UIScreen instancesRespondToSelector:@selector(currentMode)]
            &&CGSizeEqualToSize(CGSizeMake(640,1136), [[UIScreen mainScreen] currentMode].size) ) {
        return @"Brand Assets-700-568h@2x.png";
    }
    return @"Brand Assets-700@2x.png";
}

void audioPlayWithURL(NSURL * _Nonnull url) {
    
    SystemSoundID sound;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &sound);
	AudioServicesPlaySystemSound(sound);
}

void audioPlayVibrate() {
    
#if TARGET_OS_IPHONE
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#else
    AudioServicesPlaySystemSound(kSystemSoundID_UserPreferredAlert);
#endif
}

void callPhone(NSString * _Nonnull mobile, UIView * _Nonnull view) {
    
    NSArray *array = [mobile componentsSeparatedByString:@"/"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[array firstObject]] ];
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectZero];
    [view addSubview:webview];
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
}
