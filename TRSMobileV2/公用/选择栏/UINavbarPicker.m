//
//  UINavbarPicker.m
//  TRSMobileV2
//
//  Created by  TRS on 16/4/12.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UINavbarPicker.h"
#import "UINewsSubscribleItem.h"
#import "UIDevice+Extension.h"
#import "UILabel+Extension.h"
#import "UIView+Extension.h"
#import "UIView+SDAutoLayout.h"
#import "NSDictionary+Extension.h"

@interface UINavbarPicker () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgViewBg;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubscrible;

/**
 * 第一个按钮的x坐标偏移量
 */
@property (assign, nonatomic) CGFloat   x_offset;

/**
 * 默认一页显示个数
 */
@property (assign, nonatomic) NSInteger intColumn;

/**
 * 按钮的默认最小宽度
 */
@property (assign, nonatomic) CGFloat   minWidth;

@end

@implementation UINavbarPicker

- (void)awakeFromNib {
    
    [super awakeFromNib];

    _intColumn = (isiPad() ? 8 : 5);
    _scrollView.scrollsToTop = NO;
    [self setWidth:CGRectGetWidth([UIScreen mainScreen].bounds)];
    [_scrollView setWidth:CGRectGetWidth([UIScreen mainScreen].bounds)];
    [_buttonSubscrible setImage:[UIImage imageNamed:@"normal.bundle/订阅_增加.png"] forState:UIControlStateNormal];
}

- (void)setTitles:(NSArray *)titles {

    //数据检查
    if(titles == nil || titles.count == 0) {return;}
    
    //记录
    _titles = titles;
    
    //移除所有子视图
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //加载子视图
    _minWidth = CGRectGetWidth(_scrollView.bounds)/_intColumn;
    CGFloat _x = _x_offset;
    CGFloat _w = _isEqualWidth ? _minWidth : 0.0;
    for(NSInteger i = 0; i  < titles.count; i++) {
    
        id obj = titles[i];
        if(_isOnlyLoadSubscribled && (![obj[isChannelSubscrible] boolValue]) ) continue;
        
        NSString *title = [obj isKindOfClass:[NSString class]] ? obj : [obj objectForVitualKey:@"title"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.selected = (i == 0);
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:(i == 0 ? 15.0 : 14.0)];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor ] forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
        [button addDidFontChangeObserver]; //wujianjun 2016-06-18 add for 适应字体设置更改
        
        if(_isEqualWidth) {
            button.frame = CGRectMake(_x, 0, _w, CGRectGetHeight(self.frame));
        }
        else  {
            _w = [title boundingRectWithSize:CGSizeMake(120.0, 28)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName : button.titleLabel.font}
                                     context:nil].size.width;
            
            if(_w < _minWidth) {_w = _minWidth;}
            button.frame = CGRectMake(_x, 0, _w, CGRectGetHeight(self.frame));
        }
        _x += _w;
        [_scrollView addSubview:button];
    }
    _scrollView.contentSize = CGSizeMake(fmax(_x, CGRectGetWidth(_scrollView.frame)), CGRectGetHeight(self.frame));
}

- (void) setIndex:(NSInteger)index {

    if(_index == index) return;
    
    _index = index;
    UIButton *selectView = nil;
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[UIButton class] ]) {
            [(UIButton *)view setSelected:NO];
            [((UIButton *)view).titleLabel setFont:[UIFont systemFontOfSize:(view.tag == index ? 15.0 : 14.0)] ];
            if(view.tag == index) {selectView = (UIButton *)view;}
        }
    }
    
    [selectView setSelected:YES];
    [UIView animateWithDuration:0.3
                     animations:^{
                         if(_scrollView.contentSize.width > _scrollView.frame.size.width) {
                             CGFloat desiredX = selectView.center.x - (_scrollView.bounds.size.width/2);
                             if(desiredX < 0.0) desiredX = 0.0;
                             if (desiredX > (_scrollView.contentSize.width - _scrollView.bounds.size.width)) {
                                 desiredX = (_scrollView.contentSize.width - _scrollView.bounds.size.width);
                             }
                             if (!(_scrollView.bounds.size.width > _scrollView.contentSize.width)) {
                                 [_scrollView setContentOffset:CGPointMake(desiredX, 0) animated:YES];
                             }
                         }
                     }
                     completion:^(BOOL finish){
                     }
     ];
}

- (void) setIsSubscrible:(BOOL)isSubscrible {

    _buttonSubscrible.hidden = !isSubscrible;
    _scrollView.sd_layout.leftEqualToView(self).rightSpaceToView((isSubscrible ? _buttonSubscrible : self), 0);
}

- (void) didButtonSubscribleSelect:(id)sender {
    
    if(_subscribleEvent) {_subscribleEvent();}
}

- (void) didButtonSelect:(id)sender {

    NSInteger index = [(UIButton *)sender tag];
    [self setIndex:index];
    if(_clickEvent) {_clickEvent(_titles[index], index);}
}

@end
