//
//  UIView+XYPageView.m
//  XYHiRepairs
//
//  Created by krystal on 2018/7/9.
//  Copyright © 2018年 Kingnet. All rights reserved.
//

#import "UIView+XYPageView.h"

@implementation UIView (XYPageView)

- (void)setYn_x:(CGFloat)yn_x {
    CGRect frame = self.frame;
    frame.origin.x = yn_x;
    self.frame = frame;
}

- (CGFloat)yn_x {
    return self.frame.origin.x;
}

- (void)setYn_y:(CGFloat)yn_y {
    CGRect frame = self.frame;
    frame.origin.y = yn_y;
    self.frame = frame;
}

- (CGFloat)yn_y {
    return self.frame.origin.y;
}

- (CGFloat)yn_width {
    return self.frame.size.width;
}

- (void)setYn_width:(CGFloat)yn_width {
    CGRect frame = self.frame;
    frame.size.width = yn_width;
    self.frame = frame;
}

- (CGFloat)yn_height {
    return self.frame.size.height;
}

- (void)setYn_height:(CGFloat)yn_height {
    CGRect frame = self.frame;
    frame.size.height = yn_height;
    self.frame = frame;
}

- (CGFloat)yn_bottom {
    return self.frame.size.height + self.frame.origin.y;
}
@end
