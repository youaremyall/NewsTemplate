//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "UICycleScrollView.h"
#import "YYBannerView.h"
#import "UIColor+Extension.h"
#import "UILabel+Extension.h"
#import "NSTimer+Extension.h"
#import "NSDictionary+Extension.h"
#import "TRSMobile.h"

@interface UICycleScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) YYBannerView  *bannerView;
@property (nonatomic, readonly) SMPageControl *pageControl;
@property (nonatomic, strong) UIImageView    *shadow;
@property (nonatomic, strong) UILabel        *label;
@property (nonatomic, assign) CGFloat  shadowHeight;
@property (nonatomic, assign) CGFloat  pageControlWidth;

@end

@implementation UICycleScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // Initialization code
        _shadowHeight = 30.0f;  //文字阴影高度
        _pageControlWidth = 40.0f;  //默认页面指示器所占宽度
        
        _bannerView = [[YYBannerView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - _shadowHeight)];
        _bannerView.placeHoldImage = [UIImage imageNamed:@"icon_d_默认大图.png"];
        [self addSubview:_bannerView];
        
        CGRect rect = CGRectMake(0, CGRectGetHeight(_bannerView.frame), self.bounds.size.width, _shadowHeight);
		_shadow = [[UIImageView alloc] initWithFrame:rect];
		_shadow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
		[self addSubview:_shadow];
		
        rect = CGRectMake(10.0, 0.0, frame.size.width - (2* 10.0 + _pageControlWidth), _shadow.frame.size.height);
		_label = [[UILabel alloc] initWithFrame:rect];
		_label.backgroundColor = [UIColor clearColor];
		_label.font = [UIFont systemFontOfSize:14.0];
		_label.textColor = [UIColor whiteColor];
        [_label addDidFontChangeObserver]; //wujianjun 2016-06-18 add for 适应字体设置更改
		[_shadow addSubview:_label];
        
        rect = CGRectMake(10.0, 0.0, self.bounds.size.width - 2*10.0, _shadow.frame.size.height);
        _pageControl = [[SMPageControl alloc] initWithFrame:rect];
        _pageControl.alignment = SMPageControlAlignmentRight;
        _pageControl.indicatorMargin = 5.0; //指示点之间的间隔
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRGB:0xcccccc];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRGB:UIColorThemeDefault];
        _pageControl.userInteractionEnabled = NO;
        [_shadow addSubview:_pageControl];
    }
    return self;
}

#pragma mark -
- (void)setDataource:(id<UICycleScrollViewDatasource>)datasource {
    
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData {
    
    //重置计数相关
    _curPage = 0;
    _totalPages = [_datasource numberOfPages:self];
    
    //校验是否有效
    if (_totalPages == 0) {
        return;
    }
    
    //当只有一张图片时，调整label的宽度
    if(_totalPages ==  1) {
        CGRect frame = _label.frame;
        frame.size.width = self.frame.size.width - 20.0 - (_totalPages == 1 ? 0.0 : _pageControlWidth);
        [_label setFrame:frame];
    }

    //文字字体颜色
    if([_datasource respondsToSelector:@selector(titleColor:)]) {
        
        _label.textColor = [_datasource titleColor:self];
    }
    
    //设置文字后面的阴影图片
    if([_datasource respondsToSelector:@selector(backgroundShadowImage:)]) {
        
        UIImage *image = [_datasource backgroundShadowImage:self];
        if(!image) {
            _shadow.image = image;
            _shadow.frame = CGRectMake(0, self.frame.size.height - image.size.height, self.frame.size.width, image.size.height);
        }
    }
    else if([_datasource respondsToSelector:@selector(backgroundShadowColor:)]) {
        
        _shadow.backgroundColor = [_datasource backgroundShadowColor:self];
    }
    
    //设置页数指示器
    _pageControl.numberOfPages = _totalPages;
    _pageControl.hidesForSinglePage = YES;
    
    //加载数据显示
    [self loadData];
}

- (void)loadData{
    
    _pageControl.currentPage = _curPage;
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0];
    for(NSInteger i = 0; i < _totalPages; i++) {
        
        if([_datasource respondsToSelector:@selector(pageAtIndex:index:)]) {
            
            NSDictionary *dict = [_datasource pageAtIndex:self index:i];
            YYBannerModel *model = [[YYBannerModel alloc] init];
            NSArray *images = dict[@"RelPhoto"];
            model.thumb = images[0][@"picurl"];
            model.title = [dict objectForVitualKey:@"title"];
            [datas addObject:model];
            
            if(i == 0) {[_label setText:model.title];}
        }
    }
    
    __weak typeof(self) wself = self;
    __weak typeof(_label) wlabel = _label;
    __weak typeof(_pageControl) wpageControl = _pageControl;
    
    _bannerView.changeBlock = ^(YYBannerModel * _Nonnull model, int index) {
        
        [wlabel setText:model.title];
        [wpageControl setCurrentPage:index];
    };
    
    _bannerView.callBack = ^(YYBannerModel * _Nonnull model, int index) {
        
        if(_datasource && [_datasource respondsToSelector:@selector(select:index:)]) {
            [wself.datasource select:wself index:index];
        }
    };
    
    [_bannerView setYYBannerType:YYBannerType_illusion];
    [_bannerView setAutoScroll:YES];
    [_bannerView setDataWithArray:datas TitleStyle:YYBannerTitleStyleNone PageStyle:YYBannerPageStyleNone];
}

@end
