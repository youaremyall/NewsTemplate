//
//  CALayer+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/13.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "CALayer+Extension.h"

@implementation CALayer (CATransition)

- (CATransition * _Nonnull)transtionWithType:(NSString * _Nonnull)type
                                     subType:(NSString * _Nonnull)subtype
                           timingFuctionName:(NSString * _Nonnull)timingFuctionName
                                    duration:(CGFloat)duration {
    
    NSString *key = @"transition";
    if([self animationForKey:key]) {[self removeAnimationForKey:key];}
    
    CATransition *transition = [CATransition animation];
    transition.type = type;
    transition.subtype = subtype;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:timingFuctionName];
    transition.duration = duration;
    transition.removedOnCompletion = YES;
    [self addAnimation:transition forKey:key];
    return transition;
}

@end
