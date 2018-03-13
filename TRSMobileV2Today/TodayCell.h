//
//  TodayCell.h
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2017/6/17.
//  Copyright © 2017年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayCell : UITableViewCell

@property (strong, nonatomic) NSDictionary  *dict;

- (void)updateCell;

@end
