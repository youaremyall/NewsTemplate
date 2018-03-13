//
//  NSTimer+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/18.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSTimer+Extension.h"

@implementation NSTimer (Extension)

- (void)pauseTimer {
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval {
    
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end
