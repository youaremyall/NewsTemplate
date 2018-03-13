//
//  iVersionView.h
//  NXXW
//
//  Created by wangchangjun on 2017/4/12.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iVersionView : UIView

+ (void)showWithVersion:(NSString *)version releaseTime:(NSString *)relseaTime releaseNotes:(NSString *)releaseNotes releaseUrl:(NSString *)releaseUrl isForceUpdate:(BOOL)isForceUpdate;

@end
