//
//  YYRollBarView.m
//  ProductSammary
//
//  Created by admin on 16/11/17.
//  Copyright © 2016年 admin. All rights reserved.
//
#import "Masonry.h"
#import "YYRollBarView.h"
#ifndef  ColorFromHexRGBA
#define ColorFromHexRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]
#endif

@interface YYRollBarView()<UIScrollViewDelegate>
@property (nonatomic, strong)UIScrollView * scrollView;
@property (nonatomic, strong)NSTimer * timer;

@property (nonatomic,strong)UILabel * backwardLabel;
@property (nonatomic,strong)UILabel * currentLabel;
@property (nonatomic,strong)UILabel * forwardLabel;

@property (nonatomic,strong)UILabel * titleLabel;

@property (nonatomic,strong)CAShapeLayer * VerLayer;

@property (nonatomic, strong)NSArray * dataArr;
@property (nonatomic, assign,readwrite)int  currentIndex;
@property (nonatomic, assign,readwrite)int  forwardIndex;
@property (nonatomic, assign,readwrite)int  backwardIndex;

@property (nonatomic, assign)CGSize titleSize;
@end

@implementation YYRollBarView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];  
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setUp];
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
        [self resetTimer];
    }
}
-(void)dealloc{
#ifdef DEBUG
    NSLog(@"Dealloc %@",self);
#endif
}
-(void)layoutSubviews{
    [super layoutSubviews];

    _VerLayer.position = CGPointMake(_titleSize.width + 15, CGRectGetHeight(self.bounds)/2);
    _VerLayer.bounds = CGRectMake(0, 0,1.0 /[UIScreen mainScreen].scale, _titleSize.height - 6 );
}

#pragma mark ------------- Event --------------
-(void)setDataWithArray:(NSArray<NSString  *> *)dataAyy{
    if ([dataAyy[0] isKindOfClass:[NSString class]]) {
        self.dataArr = dataAyy;
        
        if (self.dataArr.count == 0) {
            return;
        }
        
        if (self.dataArr.count == 1) {
            _scrollView.contentOffset = CGPointMake(0, 0);
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds) * 1);
            _scrollView.scrollEnabled = NO;
        }
        
        if (self.dataArr.count >= 2) {
            
            _scrollView.contentOffset = CGPointMake(0, CGRectGetHeight(_scrollView.bounds));
            _scrollView.contentSize   = CGSizeMake(CGRectGetWidth(_scrollView.bounds) , CGRectGetHeight(_scrollView.bounds)* 3);
            _scrollView.scrollEnabled = YES;
        }
        self.currentIndex = 0;
        [self setContainerContent];
        
        [self resetTimer];
    }
}
- (void)pauseTimer{
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer{
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
}
- (void)resetTimer
{
    if (self.timer) {
        self.timer.fireDate = [NSDate distantFuture];
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.dataArr.count >=2 && self.autoScroll) {
        self.timer = [NSTimer timerWithTimeInterval:self.timerInterval target:self selector:@selector(step) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }else{
    }
}
-(void)setContainerContent{
    
    [self.backwardLabel setAttributedText: getAttStr((NSString *)self.dataArr[_backwardIndex])];
    [self.currentLabel setAttributedText: getAttStr((NSString *)self.dataArr[_currentIndex])];
    [self.forwardLabel setAttributedText: getAttStr((NSString *)self.dataArr[_forwardIndex])];
   
}

static NSMutableAttributedString * getAttStr(NSString * str){
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    NSShadow * shadow = [[NSShadow alloc]init];
    shadow.shadowBlurRadius = 3;
    shadow.shadowColor = [UIColor cyanColor];
    shadow.shadowOffset = CGSizeMake(1 , 2);
    
    [attrStr addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, 2)];
    [attrStr addAttribute:NSVerticalGlyphFormAttributeName value:@0 range:NSMakeRange(0, 2)];
    
//    [attrStr addAttribute:NSStrokeWidthAttributeName value:@1 range:NSMakeRange(0, 2)]; // 空心
//    [attrStr addAttribute:NSStrokeColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(0, 2)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:ColorFromHexRGBA(0xED581A, 1) range:NSMakeRange(0, 2)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:NSMakeRange(2, str.length - 2)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, str.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(str.length - 4, 1)];
    
    return attrStr;
}

//timer func
- (void)step{
    [_scrollView setContentOffset:CGPointMake(0, CGRectGetHeight(self.bounds)*2) animated:YES];
}

#pragma mark ------------- ScrollViewDelegate --------------
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self pauseTimer];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    div_t x = div(scrollView.contentOffset.y,scrollView.frame.size.height);
    
    if (x.quot == 0) {
        self.currentIndex -=1;
    }else if(x.quot == 2){
        self.currentIndex +=1;
    }
    
    [self setContainerContent];
    self.scrollView.contentOffset = CGPointMake(0, CGRectGetHeight(self.bounds) );
    
    [self resumeTimer];
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    div_t x = div(scrollView.contentOffset.y,scrollView.frame.size.height);
    
    if (x.quot == 0) {
        self.currentIndex -=1;
    }else if(x.quot == 2){
        self.currentIndex +=1;
    }
    
    [self setContainerContent];
    self.scrollView.contentOffset = CGPointMake(0, CGRectGetHeight(self.bounds) );
}

#pragma mark ------------- Setter --------------
-(void)setUp{
    self.titleSize = CGSizeMake(50, 50);
    self.timerInterval = 3.0f;
    self.autoScroll = YES;
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0,0)];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = ColorFromHexRGBA(0xED581A, 1);
    _titleLabel.text = @"直 播预 告";
    _titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
 
    
    _VerLayer = [CAShapeLayer layer];
    _VerLayer.backgroundColor = [UIColor redColor].CGColor; //fillColer <-> path
    _VerLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:_VerLayer];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(_titleSize.width + 1, 0, CGRectGetWidth(self.bounds) - _titleSize.width - 2, CGRectGetHeight(self.bounds))];
    [self addSubview:_scrollView];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    //该句是否执行会影响pageControl的位置,如果该应用上面有导航栏,就是用该句,否则注释掉即可
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _scrollView.clipsToBounds = YES;
    
    for (int i = 0 ; i <3 ; i++) {
        UILabel * imageView =  [[UILabel alloc]initWithFrame:CGRectMake(i* CGRectGetWidth(_scrollView.bounds), 0, CGRectGetWidth(_scrollView.bounds),  CGRectGetHeight(_scrollView.bounds))];
        [_scrollView addSubview:imageView];
        
        switch (i) {
            case 0:
            {
                _backwardLabel = imageView;
            }
                break;
            case 1:
            {
                _currentLabel = imageView;
            }
                break;
            case 2:
            {
                _forwardLabel = imageView;
            }
                break;
        }
    }

    {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(_titleSize);
        }];

        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.left.equalTo(self.titleLabel.mas_right).offset(15);
            make.height.equalTo(self);
        }];
        [self.backwardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView);
            make.left.equalTo(self.scrollView).mas_offset(0);
        }];
        [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView).mas_offset(CGRectGetHeight(self.bounds));
            make.left.equalTo(self.scrollView);
        }];
        [self.forwardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.scrollView);
            make.top.equalTo(self.scrollView).mas_offset(CGRectGetHeight(self.bounds) * 2);
            make.left.equalTo(self.scrollView);
        }];
    }
    
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
    //    NSLog(@"%d , %d, %d",  _backwardIndex, self.currentIndex, _forwardIndex);
}
- (void)setTimerInterval:(NSTimeInterval)timerInterval{
    _timerInterval = timerInterval;
    [self resetTimer];
}
-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    if (autoScroll == NO) {
        self.timer.fireDate = [NSDate distantFuture];
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
