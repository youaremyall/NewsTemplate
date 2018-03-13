//
//  NSBundle+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/30.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSBundle+Extension.h"

@implementation NSBundle (Extension)

+ (id _Nullable)instanceWithBundleNib:(NSString * _Nonnull)name {
    
    return [[NSBundle mainBundle] pathForResource:name ofType:@"nib"] ? [[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil] lastObject] : nil;
}

+ (id _Nullable)objectForCFBundleKey:(NSString * _Nonnull)key {
    
    id obj = [[NSBundle mainBundle].localizedInfoDictionary objectForKey:key];
    if(obj) return obj;
    
    return [[NSBundle mainBundle].infoDictionary objectForKey:key];
}

@end
