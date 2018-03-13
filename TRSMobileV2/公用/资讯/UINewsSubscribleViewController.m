//
//  UINewsSubscribleViewController.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/14.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UINewsSubscribleViewController.h"
#import "UINewsSubscribleItem.h"
#import "UIColor+Extension.h"
#import "UIDevice+Extension.h"
#import "UIView+Extension.h"
#import "UIView+SDAutoLayout.h"
#import "NSNotification+Extension.h"
#import "StroageService+Provider.h"
#import "RDVTabBarController.h"

@interface UINewsSubscribleViewController () {

    //方格显示标识
    BOOL   isGrid;
    
    //每一行的个数
    NSInteger intColumn;
    
    //按钮的大小
    CGSize  sizeItem;
    
    //距离左右上下的间距
    CGFloat space;
    
    //按钮之间的占位间隔
    CGFloat padding;
    
    /*开始拖动的view的下一个view的CGPoint*/
    CGPoint pointNext;
    
    /*用于赋值CGPoint*/
    CGPoint pointValue;
}

/*整个覆盖在window上的图层*/
@property (strong, nonatomic) UIView     *viewCoverLayer;

/*导航条顶部的透明覆盖层*/
@property (strong, nonatomic) UIView     *viewCoverTopLayer;

/*栏目已订阅标签*/
@property (strong, nonatomic) UILabel    *labelSubscribled;

/*栏目未订阅标签*/
@property (strong, nonatomic) UILabel    *labelUnSubscrible;

/*栏目已订阅编辑*/
@property (strong, nonatomic) UIButton   *buttonEdit;

/*加载已订阅和未订阅栏目的滚动容器*/
@property (strong, nonatomic) UIScrollView  *scrollView;

/*栏目已订阅数组*/
@property (strong, nonatomic) NSMutableArray *channelsSubscribled;

/*栏目待订阅数组*/
@property (strong, nonatomic) NSMutableArray *channelsUnSubscrible;

/*栏目已订阅-子栏目容器*/
@property (strong, nonatomic) NSMutableArray *viewSubscribled;

/*栏目未订阅-子栏目容器*/
@property (strong, nonatomic) NSMutableArray *viewUnSubscrible;

/*所有新闻栏目或用户编辑后的栏目数据*/
@property (strong, nonatomic) NSArray  *channels;

/*已订阅栏目的顶部视图高度*/
@property (assign, nonatomic) CGFloat heightSubscrible;

/*订阅栏目编辑状态*/
@property (assign, nonatomic) BOOL isEdit;

/*编辑状态是否隐藏未订阅栏目*/
@property (assign, nonatomic) BOOL hideUnscribleViewWhenEditing;

/*订阅栏目发生更改回调*/
@property (copy, nonatomic) void (^changeBlock)(NSArray *channels);

/*订阅栏目点击回调*/
@property (copy, nonatomic) void (^clickBlock)(NSInteger index);

@end

@implementation UINewsSubscribleViewController

#pragma mark -
/**
 * @brief 展示订阅界面
 * @param parent : 显示的父类控制器
 * @param channels : 新闻栏目数据
 * @param y : 订阅界面开始显示的y坐标
 * @param h : 订阅界面切换栏目的高度
 * @param changeBlock : 订阅栏目发生更改回调
 * @param clickBlock : 订阅栏目点击回调
 * @return 无
 */
+ (void)showInVC:(UIViewController * _Nonnull )parent
        channels:(NSArray * _Nonnull)channels
               y:(CGFloat)y
               h:(CGFloat)h
     changeBlock:(void (^_Nonnull)(NSArray * _Nonnull channels))changeBlock
      clickBlock:(void (^_Nonnull)(NSInteger index))clickBlock {
    
    /*整个覆盖在window上的图层*/
    UIView *coverLayer = [UIView new];
    coverLayer.frame = [UIScreen mainScreen].bounds;
    coverLayer.backgroundColor = [UIColor clearColor];
    
    /*导航条顶部的透明覆盖层*/
    UIView *coverTopLayer = [UIView new];
    coverTopLayer.frame = CGRectMake(0, 0, CGRectGetWidth(coverLayer.frame), y);
    coverTopLayer.backgroundColor = [UIColor clearColor];
    [coverLayer addSubview:coverTopLayer];
    
    /*覆盖在底层的图层*/
    UIView *coverBottomLayer = [UIView new];
    coverBottomLayer.frame = CGRectMake(0, CGRectGetHeight(coverTopLayer.frame), CGRectGetWidth(coverLayer.frame), CGRectGetHeight(coverLayer.frame) - CGRectGetHeight(coverTopLayer.frame));
    coverBottomLayer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [coverLayer addSubview:coverBottomLayer];
    
    /*栏目订阅显示的覆盖层*/
    UINewsSubscribleViewController *vc = [UINewsSubscribleViewController new];
    vc.changeBlock = changeBlock;
    vc.clickBlock = clickBlock;
    vc.viewCoverLayer = coverLayer;
    vc.viewCoverTopLayer = coverTopLayer;
    vc.channels = channels;
    vc.heightSubscrible = h;
    vc.view.y = y;
    
    [([UIApplication sharedApplication].delegate).window addSubview:coverLayer];
    [([UIApplication sharedApplication].delegate).window addSubview:vc.view];
    [parent addChildViewController:vc];
    
    coverLayer.height = 0.0;
    vc.view.height = 0.0;
    [vc.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.3
                     animations:^{
                         vc.view.height = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(coverTopLayer.frame);
                         coverLayer.height = CGRectGetHeight([UIScreen mainScreen].bounds);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUILayout];
    [self loadNewsSubscribleLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) initUILayout {
    
    self.view.backgroundColor = [UIColor colorWithRGB:0xeeeeee alpha:0.6];
    
    //初始化参数
    [self initUIParameter];
    
    //初始化滚动视图
    [self initUIScrollView];
    
    //初始化已订阅视图
    [self initUISubscribled];
    
    //初始化未订阅视图
    [self initUIUnSubscrible];
}

- (void) initUIParameter {

    isGrid = NO;
    intColumn = (isiPad() ? 6 : 4);
    space = (IsIphone6Later ? 20.0 : 10.0);
    padding = isGrid ? 5.0 : space;
    
    CGFloat w = (CGRectGetWidth(self.view.frame) -  2 * (isGrid ? space : 0.0) - (intColumn + 1) * padding)/intColumn;
    sizeItem = CGSizeMake(w, (isGrid ? w : 36.0));
}

- (void) initUIScrollView {
    
    _scrollView = [UIScrollView new];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    _scrollView.sd_layout.xIs(0).yIs(_heightSubscrible).widthIs(CGRectGetWidth(self.view.frame)).heightIs(CGRectGetHeight(self.view.frame) - _heightSubscrible);
}

- (void) initUISubscribled {

    //导航条顶部的透明覆盖层
    [_viewCoverTopLayer addTapGesture:self selector:@selector(didButtonCancel:)];

    //栏目已订阅视图
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _heightSubscrible);
    view.backgroundColor = [UIColor whiteColor];
    
    //切换栏目
    _labelSubscribled = [UILabel new];
    _labelSubscribled.frame = CGRectMake(space, 0, 180.0, CGRectGetHeight(view.frame));
    _labelSubscribled.textColor = [UIColor darkGrayColor];
    _labelSubscribled.text = @"切换栏目";
    [view addSubview:_labelSubscribled];
    
    //排序删除(完成)
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.backgroundColor = [UIColor clearColor];
    button1.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 setTitle:@"排序删除" forState:UIControlStateNormal];
    [button1 setTitle:@"完成" forState:UIControlStateSelected];
    [button1 addTarget:self action:@selector(editSubscribled:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button1];
    _buttonEdit = button1;
    
    //返回
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor clearColor];
    button2.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button2 setTitle:@"返回" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(didButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button2];
    [self.view addSubview:view];
    
    //自动布局
    button2.sd_layout.rightSpaceToView(view, 8.0).topEqualToView(view).bottomEqualToView(view).widthIs(44.0);
    button1.sd_layout.rightSpaceToView(button2, 8.0).topEqualToView(view).bottomEqualToView(view).widthIs(60.0);
}

- (void) initUIUnSubscrible {

    //未订阅栏目视图
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    //点击添加更多栏目
    _labelUnSubscrible = [UILabel new];
    _labelUnSubscrible.text = @"点击添加更多栏目";
    [view addSubview:_labelUnSubscrible];
    [_scrollView addSubview:view];
    
    view.sd_layout.xIs(0).widthIs(CGRectGetWidth(self.view.frame)).heightIs(_heightSubscrible);
    _labelUnSubscrible.sd_layout.leftSpaceToView(view, space).rightSpaceToView(view, space).topEqualToView(view).bottomEqualToView(view);
}

#pragma mark -
- (void) loadNewsSubscribleData {
    
    if(!_channelsSubscribled) _channelsSubscribled =  [NSMutableArray arrayWithCapacity:0];
    if(!_channelsUnSubscrible)_channelsUnSubscrible = [NSMutableArray arrayWithCapacity:0];
    if(!_viewSubscribled) _viewSubscribled = [NSMutableArray arrayWithCapacity:0];
    if(!_viewUnSubscrible)_viewUnSubscrible = [NSMutableArray arrayWithCapacity:0];
    
    //清除原有数据和子视图
    [_viewSubscribled makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_viewUnSubscrible makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_channelsSubscribled removeAllObjects]; [_channelsUnSubscrible removeAllObjects];
    [_viewSubscribled removeAllObjects]; [_viewUnSubscrible removeAllObjects];
    
    for(NSDictionary *dict in _channels) {
        if([dict[isChannelSubscrible] boolValue]) {
            [_channelsSubscribled addObject:dict];
        }
        else {
            [_channelsUnSubscrible addObject:dict];
        }
    }
}

- (void) loadNewsSubscribleLayout {

    //加载数据
    [self loadNewsSubscribleData];
    
    //已订阅
    CGFloat x = space; CGFloat y = space;
    NSInteger total = _channelsSubscribled.count;
    for(NSInteger i = 0; i < total; i++) {
        
        UINewsSubscribleItem *item = [[UINewsSubscribleItem alloc] initWithFrame:CGRectMake(x, y, sizeItem.width, sizeItem.height)];
        item.tag = i;
        item.dict = _channelsSubscribled[i];
        item.isEdit = _isEdit;
        item.isSubscrible = YES;
        [item.button addTarget:self action:@selector(didButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [item.buttonDelete addTarget:self action:@selector(didButtonDelete:) forControlEvents:UIControlEventTouchUpInside];
        [item addLongPressGesture:self selector:@selector(longPressGestureRecognizer:)];
        [_viewSubscribled addObject:item];
        [_scrollView addSubview:item];
        
        //计算下一个按钮放置位置.
        x = (CGRectGetMaxX(item.frame) + padding);
        if ( x > CGRectGetWidth(self.view.frame) - (sizeItem.width + space) ) { //若此行放不下下一个按钮，则换行同时把此行最后的一个宽度拉伸填充.
            x = space;
            y += sizeItem.height + (i == total - 1 ? 0.0 : padding);
        }
        
        //最后一个是否需要换行
        if(i == total - 1) {
            y += (x > space ? (sizeItem.height + space) : space);
        }
    }
    
    //点击添加更多栏目
    _labelUnSubscrible.superview.sd_layout.yIs(y);

    //未订阅
    x = space; y += (CGRectGetHeight(_labelUnSubscrible.superview.frame) + space);
    total = _channelsUnSubscrible.count;
    for(NSInteger i = 0; i < total; i++) {
        
        UINewsSubscribleItem *item = [[UINewsSubscribleItem alloc] initWithFrame:CGRectMake(x, y, sizeItem.width, sizeItem.height)];
        item.tag = 0x20001 + i;
        item.dict = _channelsUnSubscrible[i];
        [item.button addTarget:self action:@selector(didButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [item.buttonDelete addTarget:self action:@selector(didButtonDelete:) forControlEvents:UIControlEventTouchUpInside];
        [item addLongPressGesture:self selector:@selector(longPressGestureRecognizer:)];
        [_viewUnSubscrible addObject:item];
        [_scrollView addSubview:item];
        
        //计算下一个按钮放置位置.
        x = (CGRectGetMaxX(item.frame) + padding);
        if ( x > CGRectGetWidth(self.view.frame) - (sizeItem.width + space)) { //若此行放不下下一个按钮，则换行同时把此行最后的一个宽度拉伸填充.
            x = space;
            y += sizeItem.height + (i == total - 1 ? 0.0 : padding);
        }
        
        //最后一个是否需要换行
        if(i == total - 1) {
            y += (x > space ? (sizeItem.height + space) : space);
        }
    }
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fmax(CGRectGetHeight(_scrollView.frame) + space, y + 64.0));
}

- (void) loadAnimation:(BOOL)animated {

    //已订阅
    __block CGFloat x = space; __block CGFloat y = space;
    NSInteger total = _viewSubscribled.count;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         for(NSInteger i = 0; i < total; i++) {
                             
                             UINewsSubscribleItem *item = _viewSubscribled[i];
                             item.sd_layout.xIs(x).yIs(y);
                             item.tag = i;
                             item.isEdit = _isEdit;
                             item.isSubscrible = YES;

                             //计算下一个按钮放置位置.
                             x = (CGRectGetMaxX(item.frame) + padding);
                             if ( x > CGRectGetWidth(self.view.frame) - (sizeItem.width + space) ) { //若此行放不下按钮，同时把此行最后的一个宽度拉伸填充.
                                 x = space;
                                 y += sizeItem.height + (i == total - 1 ? 0.0 : padding);
                             }
                             
                             //最后一个是否需要换行
                             if(i == total - 1) {
                                 y += (x > space ? (sizeItem.height + space) : space);
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
    
    
    //点击添加更多栏目
    _labelUnSubscrible.superview.sd_layout.yIs(y);

    //未订阅
    x = space; y += (CGRectGetHeight(_labelUnSubscrible.superview.frame) + space);
    total = _viewUnSubscrible.count;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         for(NSInteger i = 0; i < total; i++) {
                             
                             UINewsSubscribleItem *item = _viewUnSubscrible[i];
                             item.sd_layout.xIs(x).yIs(y);
                             item.tag = 0x20001 + i;
                             item.isEdit = NO;
                             item.isSubscrible = NO;
                             [item setHidden:(animated && _hideUnscribleViewWhenEditing)];
                             
                             //计算下一个按钮放置位置.
                             x = (CGRectGetMaxX(item.frame) + padding);
                             if ( x > CGRectGetWidth(self.view.frame) - (sizeItem.width + space) ) { //若此行放不下按钮，同时把此行最后的一个宽度拉伸填充.
                                 x = space;
                                 y += sizeItem.height + (i == total - 1 ? 0.0 : padding);
                             }
                             
                             //最后一个是否需要换行
                             if(i == total - 1) {
                                 y += (x > space ? (sizeItem.height + space) : space);
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), fmax(CGRectGetHeight(_scrollView.frame) + space, y + 64.0));
}

- (void) setSubscribledEdit:(BOOL) isEdit {

    //记录状态
    _isEdit =  isEdit;
    
    [_buttonEdit setSelected:isEdit];
    [_labelSubscribled setText:(isEdit ? @"拖动排序" : @"切换栏目")];
    
    [_labelUnSubscrible.superview setHidden:(isEdit && _hideUnscribleViewWhenEditing)];
    for(UINewsSubscribleItem *view in _viewSubscribled) {[view setIsEdit:isEdit];}
    for(UINewsSubscribleItem *view in _viewUnSubscrible) {[view setHidden:(isEdit && _hideUnscribleViewWhenEditing)];}
}

- (BOOL)isSame2ChannelsOld {

    NSMutableArray *channels__ = [NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *dict in _channelsSubscribled) {
        NSMutableDictionary*dict_ = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dict_ setObject:@(1) forKey:isChannelSubscrible];
        [channels__ addObject:dict_];
    }
    for(NSDictionary *dict in _channelsUnSubscrible) {
        NSMutableDictionary*dict_ = [NSMutableDictionary dictionaryWithDictionary:dict];
        [dict_ setObject:@(0) forKey:isChannelSubscrible];
        [channels__ addObject:dict_];
    }
    
    BOOL isSame = [_channels isEqualToArray:channels__];
    if(!isSame) {
        _channels = channels__;
        [StroageService setValue:_channels forKey:UserNewsChannel serviceType:serviceTypeUser];
    }
    
    return isSame;
}

- (void)dismiss:(BOOL)clicked index:(NSInteger)index{

    if(![self isSame2ChannelsOld]) {
        if(_changeBlock) {_changeBlock(_channels);}
    }
    
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.height = 0.0;
                         _viewCoverLayer.height = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [_viewCoverLayer removeFromSuperview];
                         [self viewWillDisappear:YES];
                         [self removeFromParentViewController];
                         if(clicked && index != -1) {
                             if(_clickBlock) {_clickBlock(index);}
                         }
                     }];
}

#pragma mark - Action
- (void) editSubscribled:(UIButton *)sender {
    
    [self setSubscribledEdit:(!sender.isSelected)];
}

- (void) didButtonCancel:(UIButton *)sender {
    
    [self dismiss:NO index:-1];
}

- (void) didButtonAdd:(UIButton *)sender {
    
    UINewsSubscribleItem *item = (UINewsSubscribleItem *)sender.superview;
    
    // 同步数据
    [_channelsUnSubscrible removeObject:item.dict];
    [_channelsSubscribled addObject:item.dict ];

    // 加载动画
    [_viewUnSubscrible removeObject:item];
    [_viewSubscribled addObject:item];
    [self loadAnimation:NO];
}

- (void) didButtonDelete:(UIButton *)sender {

    UINewsSubscribleItem *item = (UINewsSubscribleItem *)sender.superview;
    
    // 同步数据
    [_channelsSubscribled removeObject:item.dict];
    [_channelsUnSubscrible addObject:item.dict ];

    // 加载动画
    [_viewSubscribled removeObject:item];
    [_viewUnSubscrible addObject:item];
    [self loadAnimation:YES];
}

- (void) didButtonClick:(UIButton *)sender {
    
    UINewsSubscribleItem *item = (UINewsSubscribleItem *)sender.superview;
    if(item.isSubscrible) { //已订阅栏目按钮点击
        if(!_isEdit) { //切换栏目
            [self dismiss:YES index:item.tag];
        }
        else {
            /*固定栏目不可删除*/
            if([item.dict[isChannelFix] boolValue]) {return;}
            [self didButtonDelete:sender];
        }
    }
    else { //未订阅栏目按钮点击
        [self didButtonAdd:sender];
    }
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {

    // 禁用其他按钮的拖拽手势
    UIButton *recognizerView = (UIButton *)recognizer.view;
    
    // 已订阅-固定栏目或未订阅栏目禁止长按拖拽手势
    if([((UINewsSubscribleItem *)recognizerView).dict[isChannelFix] boolValue]
       || (![(UINewsSubscribleItem *)recognizerView isSubscrible])) {return;}
    
    //其它
    for (UIButton *bt in _viewSubscribled) {
        if (bt != recognizerView) {
            bt.userInteractionEnabled = NO;
        }
    }
    
    // 长按视图在父视图中的位置（触摸点的位置）
    CGPoint recognizerPoint = [recognizer locationInView:self.scrollView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self setSubscribledEdit:YES];
        
        // 开始的时候改变拖动view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.3 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            recognizerView.alpha = 0.6;
        }];
        
        // 把拖动view放到最上层
        [self.view bringSubviewToFront:recognizerView];
        
        // valuePoint保存最新的移动位置
        pointValue = recognizerView.center;
        
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        // 更新pan.view的center
        recognizerView.center = recognizerPoint;
        
        /**
         * 可以创建一个继承UIButton的类(MyButton)，这样便于扩展，增加一些属性来绑定数据
         * 如果在self.view上加其他控件拖拽会奔溃，可以在下面方法里面加判断MyButton，也可以把所有按钮放到一个全局变量的UIView上来替换self.view
         */
        for (UIButton * bt in _viewSubscribled) {
            
            // 固定栏目不可排序
            if([[(UINewsSubscribleItem *)bt dict][isChannelFix] boolValue]) {continue;}
            
            // 判断是否移动到另一个view区域
            // CGRectContainsPoint(rect,point) 判断某个点是否被某个frame包含
            if (CGRectContainsPoint(bt.frame, recognizerView.center)
                && bt != recognizerView) {
                
                // 开始位置
                NSInteger fromIndex = recognizerView.tag;
                
                // 需要移动到的位置
                NSInteger toIndex = bt.tag;
                
                // 往后移动
                if ((toIndex-fromIndex)>0) {
                    
                    // 从开始位置移动到结束位置
                    // 把移动view的下一个view移动到记录的view的位置(valuePoint)，并把下一view的位置记为新的nextPoint，并把view的tag值-1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex+1; i<=toIndex; i++) {
                            UIButton * nextBt = (UIButton*)[self.scrollView viewWithTag:i];
                            pointNext = nextBt.center;
                            nextBt.center = pointValue;
                            pointValue = pointNext;
                            
                            nextBt.tag--;
                        }
                        recognizerView.tag = toIndex;
                    }];
                }
                // 往前移动
                else
                {
                    // 从开始位置移动到结束位置
                    // 把移动view的上一个view移动到记录的view的位置(valuePoint)，并把上一view的位置记为新的nextPoint，并把view的tag值+1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex-1; i>=toIndex; i--) {
                            UIButton * nextBt = (UIButton*)[self.scrollView viewWithTag:i];
                            pointNext = nextBt.center;
                            nextBt.center = pointValue;
                            pointValue = pointNext;
                            
                            nextBt.tag++;
                        }
                        recognizerView.tag = toIndex;
                    }];
                }
                
                // 同步已订阅栏目数据排序
                id obj = _channelsSubscribled[fromIndex];
                [_channelsSubscribled removeObjectAtIndex:fromIndex];
                [_channelsSubscribled insertObject:obj atIndex:toIndex];
            }
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded){
        
        // 恢复其他按钮的拖拽手势
        for (UIButton * bt in _viewSubscribled) {
            if (bt != recognizerView) {
                bt.userInteractionEnabled = YES;
            }
        }
        
        // 结束时候恢复view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.3
                         animations:^{
                            recognizerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                            recognizerView.alpha = 1;            
                            recognizerView.center = pointValue;
                         }
                         completion:^(BOOL finished) {
                             
                             // 同步已订阅栏目显示排序
                             [_viewSubscribled sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                 return [(UINewsSubscribleItem *)obj1 tag] > [(UINewsSubscribleItem *)obj2 tag];
                             }];
                         }];
    }
}

@end
