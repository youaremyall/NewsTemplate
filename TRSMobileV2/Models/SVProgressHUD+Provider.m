//
//  SVProgressHUD+Provider.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/11.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "SVProgressHUD+Provider.h"

@implementation SVProgressHUD_Provider

+ (void)load {

    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
}

@end
