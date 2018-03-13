//
//  QRViewController.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/24.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIBaseViewController.h"

@interface QRViewController : UIBaseViewController

/**
 * 二维码扫描或生成回调
 * object字段为NSString 或 UIImage对象
 */
@property (copy, nonatomic) void (^successBlock)(id object, BOOL isScan);

@end
