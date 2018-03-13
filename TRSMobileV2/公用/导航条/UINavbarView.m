//
//  UINavbarView.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/11.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINavbarView.h"
#import "UIView+Extension.h"

@implementation UINavbarView

- (void) awakeFromNib {

    [super awakeFromNib];

    _barBackground.clipsToBounds = YES;
    [self setWidth:CGRectGetWidth([UIScreen mainScreen].bounds)];
    [_barTitle setFont:[UIFont systemFontOfSize:20.0] ];
}

- (IBAction)didButtonSelect:(id)sender {
    
    if(_clickEvent) {_clickEvent(nil, [(UIButton *)sender tag]);};
}

@end
