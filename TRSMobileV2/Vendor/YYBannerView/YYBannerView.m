//
//  YYBannerView.m
//  新型轮播图
//
//  Created by admin on 16/11/14.
//  Copyright © 2016年 xincheng. All rights reserved.
//
#import "Masonry.h"
#import "YYBannerView.h"
#import "YYBannerContentView.h"
#import <objc/runtime.h>
#ifndef  ColorFromHexRGBA
#define ColorFromHexRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]
#endif

@interface YYBannerView()<UIScrollViewDelegate>
{
    BOOL _autoScroll;
}

@property (nonatomic, strong)UIScrollView * scrollView;
@property (retain,nonatomic,readwrite) UIPageControl * pageControl;

@property (nonatomic, strong)NSTimer * timer;

@property (nonatomic, strong)YYBannerContentView * leftImageView;
@property (nonatomic, strong)YYBannerContentView * centerImageView;
@property (nonatomic, strong)YYBannerContentView * rightImageView;
@property (nonatomic,strong)UILabel * titleLabel;
@property (nonatomic,strong)CAGradientLayer * titleBackLayer;
@property (nonatomic, strong)UIView * titleBackView;

@property (nonatomic, strong)NSArray * dataArr;
@property (nonatomic, assign,readwrite)int  currentIndex;
@property (nonatomic, assign,readwrite)int  forwardIndex;
@property (nonatomic, assign,readwrite)int  backwardIndex;

@property (nonatomic, assign,readwrite)YYBannerType bannerType;
@property (nonatomic, assign,readwrite)YYBannerPageStyle bannerPageType;
@property (nonatomic, assign,readwrite)YYBannerTitleStyle bannerTitleType;

@end

@implementation YYBannerView
#pragma mark ****************************** life cycle          ******************************

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:YYBannerType_normal];
}
- (instancetype)initWithFrame:(CGRect)frame type:(YYBannerType)type;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setYYBannerType:type];
        [self setUp];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];

    [self setUp];
}
-(void)dealloc{
#ifdef DEBUG
    NSLog(@"Dealloc %@",self);
#endif
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.scrollView.contentSize, CGSizeZero)) {
        
        //dependent data
        self.currentIndex = 0;
        [self resetTimer];
       
        self.titleBackLayer.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.titleBackView.bounds)/2);
        self.titleBackLayer.bounds = self.titleBackView.bounds;

        if (self.dataArr.count == 1) {
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * 1, CGRectGetHeight(self.bounds));
            _scrollView.scrollEnabled = NO;
           //[_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        if (self.dataArr.count >= 2) {
            
            _scrollView.contentSize   = CGSizeMake(CGRectGetWidth(self.bounds) * 3, CGRectGetHeight(self.bounds));
            _scrollView.scrollEnabled = YES;
            //[_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0) animated:YES];
        }
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.dataArr.count == 1) {
                _scrollView.contentOffset = CGPointMake(0, 0);
            }
            if (self.dataArr.count >= 2) {
                _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
            }
        });
    }
}

//这个方法会在子视图添加到父视图或者离开父视图时调用
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
    if (!newSuperview)
    {
        self.timer.fireDate = [NSDate distantFuture];
        [self.timer invalidate];
        self.timer = nil;
    }
    else
    {
        self.timerInterval = 3.0f;
        self.autoScroll = YES;
        self.bannerType = YYBannerType_normal;
    }
}

-(void)setYYBannerType:(YYBannerType)type{
    self.bannerType = type;
}
-(void)setDataWithArray:(NSArray<YYBannerModel  *> *)dataAyy TitleStyle:(YYBannerTitleStyle)Tstyle PageStyle:(YYBannerPageStyle)Pstyle{
    if ([dataAyy[0] isKindOfClass:[YYBannerModel class]]) {
        self.dataArr = dataAyy;
        self.bannerTitleType = Tstyle;
        self.bannerPageType = Pstyle;
        
        if (self.dataArr.count == 0) {
            return;
        }
        //layoutIfneed set content size （adapt autolayout）
        [self layoutIfNeeded];
        
        self.titleLabel.hidden = NO;
        self.pageControl.hidden = NO;
        
        switch (Tstyle) {
           
            case YYBannerTitleStyleLeft:
            {
                self.titleLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            case YYBannerTitleStyleRight:
            {
                self.titleLabel.textAlignment = NSTextAlignmentRight;
                break;
            }
            case YYBannerTitleStyleCenter:
            {
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case YYBannerTitleStyleNone:
            {
                self.titleLabel.hidden = YES;
                self.titleBackLayer.hidden = YES;
                break;
            }
        }
        
        switch (Pstyle) {
            case YYBannerPageStyleNone:
            {
                self.pageControl.hidden = YES;
                 break;
            }
            case YYBannerPageStyleLeft:
            {
                [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_offset(self.dataArr.count * 26);
                    make.left.bottom.top.mas_equalTo(self.titleBackView);
                }];
                break;
            }
            case YYBannerPageStyleRight:
            {
                [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_offset(self.dataArr.count * 26);
                    make.right.bottom.top.mas_equalTo(self.titleBackView);
                }];
                break;
            }
            case YYBannerPageStyleCenter:
            {
                break;
            }
        }
        
        self.pageControl.numberOfPages = self.dataArr.count;
    
        [self setContainerImageViews];
    }
    
    if(dataAyy.count == 1) { //修正只有一张图片时，点击无响应的问题。
        
        __weak typeof(self) Wself = self;
        [_leftImageView setUserInteraction:YES];
        [_leftImageView setCallBack:^(YYBannerContentView *sender) {
            [Wself tapFuncCallBack];
        }];
    }
}

- (void)pauseTimer{
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer{
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.timerInterval];
}
- (void)resetTimer
{
    if (self.timer) {
        self.timer.fireDate = [NSDate distantFuture];
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.dataArr.count >=2 ) {
        if (self.autoScroll) {
            self.timer = [NSTimer timerWithTimeInterval:self.timerInterval target:self selector:@selector(step) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }else{
        self.pageControl.hidden = YES;
    }
}
//timer func
- (void)step{
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*2, 0) animated:YES];
}

#pragma mark ****************************** System Delegate     ******************************
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
//    CGFloat pag = scrollView.contentOffset.x/scrollView.frame.size.width;
//    int num = (pag- (int)pag) > 0.5 ? (int)pag + 1 : (int)pag;
//    self.currentIndex = num;

    if(_changeBlock) {_changeBlock(_dataArr[_currentIndex], _currentIndex);}
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (self.bannerType) {
            case YYBannerType_normal:
            {
               break;
            }
            case YYBannerType_illusion:
            {
                [obj setOffsetWithFactor:0.8];
                break;
            }
            case YYBannerType_UNillusion:
            {
                [obj setOffsetWithFactor:1];
                break;
            }
        }
    }];
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    scrollView.contentInset = UIEdgeInsetsZero;
    [self pauseTimer];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    div_t x = div(scrollView.contentOffset.x,scrollView.frame.size.width);

    if (x.quot == 0) {
        self.currentIndex -=1;
    }else if(x.quot == 2){
        self.currentIndex +=1;
    }
    
    [self setContainerImageViews];
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.bounds), 0);
    
    [self resumeTimer];
    
    //NSLog(@"Decelerating  %d" ,self.currentIndex);
}

//call timer
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    div_t x = div(scrollView.contentOffset.x,scrollView.frame.size.width);
    
    if (x.quot == 0) {
        self.currentIndex -=1;
    }else if(x.quot == 2){
        self.currentIndex +=1;
    }
    //NSLog(@"anima  %d" ,self.currentIndex);
    [self setContainerImageViews];
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.bounds), 0);
}

#pragma mark ****************************** event   Response    ******************************
-(void)setContainerImageViews{
    
    //NSLog(@"%d" ,self.currentIndex);
    self.titleLabel.text = ((YYBannerModel *)self.dataArr[_currentIndex]).title;
    [self.leftImageView setContentIMGWithStr:((YYBannerModel *)self.dataArr[_backwardIndex]).thumb palceHolder:self.placeHoldImage];
    [self.centerImageView setContentIMGWithStr:((YYBannerModel *)self.dataArr[_currentIndex]).thumb palceHolder:self.placeHoldImage];
    [self.rightImageView setContentIMGWithStr:((YYBannerModel *)self.dataArr[_forwardIndex]).thumb palceHolder:self.placeHoldImage];
}
-(void)tapFuncCallBack
{
    YYBannerModel * model = self.dataArr[self.currentIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(YYBannerView:bannerModel:index:)]) {
        [self.delegate YYBannerView:self bannerModel:model index:self.currentIndex];
    }
    if (self.callBack) {
        self.callBack(model,self.currentIndex);
    }
    
}
#pragma mark ****************************** private Methods     ******************************

#pragma mark ****************************** getter and setter   ******************************

-(void)setUp{
    
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    //该句是否执行会影响pageControl的位置,如果该应用上面有导航栏,就是用该句,否则注释掉即可
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _scrollView.clipsToBounds = YES;
    
    for (int i = 0 ; i <3 ; i++) {
        YYBannerContentView * imageView =  [[YYBannerContentView alloc]initWithFrame:CGRectMake(i* CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds))];
        [_scrollView addSubview:imageView];
        
        switch (i) {
            case 0:
            {
                _leftImageView = imageView;
            }
                break;
            case 1:
            {
                _centerImageView = imageView;
                [_centerImageView setUserInteraction:YES];
            }
                break;
            case 2:
            {
                _rightImageView = imageView;
            }
                break;
        }
    }
    
    self.titleBackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 36, CGRectGetWidth(self.bounds), 36)];
    self.titleBackView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleBackView];
    
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    //颜色数组
    gradientLayer.colors = @[(__bridge id)ColorFromHexRGBA(0x111111, 0.8).CGColor,
                             (__bridge id)ColorFromHexRGBA(0x515151, 0.00).CGColor];
    //可以不设置
    gradientLayer.locations = @[@0.1,
                                @0.9];
    //startPoint endPoint 确定条纹方向 不设置 默认水平默认值[.5,0]和[.5,1]  左上角坐标是{0, 0}，右下角坐标是{1, 1}。
    gradientLayer.startPoint = CGPointMake(0.5, 1);
    gradientLayer.endPoint = CGPointMake(0.5, 0);
    gradientLayer.type = kCAGradientLayerAxial;
    gradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
    self.titleBackLayer = gradientLayer;
    [self.titleBackView.layer insertSublayer:gradientLayer atIndex:0];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 36, CGRectGetWidth(self.bounds), 36)];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleBackView addSubview:self.titleLabel];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 36, CGRectGetWidth(self.bounds), 36)];
    [self.titleBackView addSubview:self.pageControl];
    
    {
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView);
            make.left.equalTo(self.scrollView).mas_offset(0);
        }];
        [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView);
            make.left.equalTo(self.leftImageView.mas_right);
        }];
        [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView);
            make.left.equalTo(self.centerImageView.mas_right);
        }];
        
        [self.titleBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self);
            make.height.mas_equalTo(36);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleBackView);
        }];
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleBackView);
        }];
    }
   
    __weak typeof(self) WeakSelf = self;
    _centerImageView.callBack = ^(YYBannerContentView * sender){
        [WeakSelf tapFuncCallBack];
    };
    [self resetTimer];
}

-(void)setCurrentIndex:(int)currentIndex{
    _currentIndex = currentIndex;
    _forwardIndex = _currentIndex + 1;
    _backwardIndex = _currentIndex - 1;
    
    if (_currentIndex == (int)self.dataArr.count - 1) {
        _forwardIndex = 0;
    }
    if (_currentIndex > (int)self.dataArr.count - 1) {
        _currentIndex = 0;
        _forwardIndex = 1;
    }
    if (_currentIndex == 0) {
        _backwardIndex = (int)self.dataArr.count -1;
    }
    if (_currentIndex < 0) {
        _currentIndex = (int)self.dataArr.count -1;
        _backwardIndex = _currentIndex - 1;
    }
    self.pageControl.currentPage = _currentIndex;
//  NSLog(@"%d , %d, %d",  _backwardIndex, self.currentIndex, _forwardIndex);
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    if (_autoScroll == NO) {
        self.timer.fireDate = [NSDate distantFuture];
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)setDataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
}
-(BOOL)autoScroll{
    return _autoScroll;
}
- (void)setTimerInterval:(NSTimeInterval)timerInterval{
    _timerInterval = timerInterval;
    [self resetTimer];
}
//[self.pageControl setValue:currentImage forKey:@"_currentPageImage"];
//[self.pageControl setValue:otherImage forKey:@"_pageImage"];
@end
