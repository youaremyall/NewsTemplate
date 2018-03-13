//
//  UINewsSubscribleItem.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/19.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UINewsSubscribleItem.h"
#import "UIView+Extension.h"
#import "NSDictionary+Extension.h"

@interface UINewsSubscribleItem ()

@end

@implementation UINewsSubscribleItem

- (instancetype) initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor whiteColor];
        _button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [_button.titleLabel setFont:[UIFont systemFontOfSize:(IsIphone6Later ? 14.0 : 13.0)] ];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_button];
        
        _buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonDelete.frame = CGRectMake(frame.size.width - 16.0 + 16.0/2.0, -16.0/2.0, 16.0, 16.0);
        _buttonDelete.backgroundColor = [UIColor clearColor];
        _buttonDelete.hidden = YES;
        [_buttonDelete setImage:[UIImage imageNamed:@"normal.bundle/订阅_删除.png"] forState:UIControlStateNormal];
        [_buttonDelete.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_buttonDelete];
    }
    return self;
}

- (void)setIsCorner:(BOOL)isCorner {

    if(isCorner) {[_button setCornerWithRadius:CGRectGetHeight(_button.frame)/2.0];}
}

- (void)setIsEdit:(BOOL)isEdit {

    if([_dict[isChannelFix] boolValue]) return;
    
    _buttonDelete.hidden = !isEdit;
    [self animationShake:isEdit];
}

- (void)setDict:(NSDictionary *)dict {

    _dict = dict;
    [_button setTitle:[dict objectForVitualKey:@"title"] forState:UIControlStateNormal];
    
    if([dict[isChannelFix] boolValue]) {
        [_button setCornerWithRadius:0.0];
        [_button setBackgroundColor:[UIColor clearColor] ];
        [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}

@end
