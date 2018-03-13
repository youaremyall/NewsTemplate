//
//  CALayer+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/4/13.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (CATransition)

/**
 * @brief 图层动画
 */
- (CATransition * _Nonnull)transtionWithType:(NSString * _Nonnull)type
                                     subType:(NSString * _Nonnull)subtype
                           timingFuctionName:(NSString * _Nonnull)timingFuctionName
                                    duration:(CGFloat)duration;

@end


