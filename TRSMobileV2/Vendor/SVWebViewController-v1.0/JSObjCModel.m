//
//  JSObjCModel.m
//  SCNews
//
//  Created by  TRS on 2016/10/24.
//  Copyright © 2016年 TRS. All rights reserved.
//

#import "JSObjCModel.h"
#import "Globals.h"

@implementation JSObjCModel

- (NSString *)getUserInfo {
    
    return ([AVUser currentUser] ? [AVUser currentUser].sessionToken : @"");
}

@end
