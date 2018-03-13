//
//  JSObjCModel.h
//  SCNews
//
//  Created by  TRS on 2016/10/24.
//  Copyright © 2016年 TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSH5Delegate <JSExport>

- (NSString *)getUserInfo;

@end

@interface JSObjCModel : NSObject <JSH5Delegate>

@property (weak, nonatomic) UIViewController  *controller;

@end
