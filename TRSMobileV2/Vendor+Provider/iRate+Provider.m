//
//  iRate+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "iRate+Provider.h"

@implementation iRate (iRate_Provider)

+ (void)initialize {
    
    [iRate sharedInstance].applicationBundleID = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
    [iRate sharedInstance].onlyPromptIfLatestVersion = YES;
    [iRate sharedInstance].daysUntilPrompt = 5;
}

@end
