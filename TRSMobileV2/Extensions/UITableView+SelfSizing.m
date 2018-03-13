//
//  UITableView+SelfSizing.m
//  MobileEditing
//
//  Created by  TRS on 2017/10/25.
//  Copyright © 2017年 trs. All rights reserved.
//

#import "UITableView+SelfSizing.h"

@implementation UITableView (UITableView_SelfSizing)

+ (void)load {
    
    if (@available(iOS 11.0, *)) {
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
    }
}

@end
