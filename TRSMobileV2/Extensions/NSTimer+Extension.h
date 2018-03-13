//
//  NSTimer+Extension.h
//  TRSMobileV2
//
//  Created by  TRS on 16/5/18.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Extension)

/**
 * @brief 暂停计时器
 */
- (void)pauseTimer;

/**
 * @brief 继续计时器
 */
- (void)resumeTimer;

/**
 * @brief 等待多少秒后继续计时器
 */
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end
