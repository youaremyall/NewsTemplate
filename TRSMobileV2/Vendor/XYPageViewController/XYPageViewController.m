//
//  XYPageViewController.m
//  XYHiRepairs
//
//  Created by krystal on 2018/7/9.
//  Copyright © 2018年 Kingnet. All rights reserved.
//

#define kYNPAGE_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define kYNPAGE_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define kYNPAGE_IS_IPHONE_X  ((kYNPAGE_SCREEN_HEIGHT == 812.0f && kYNPAGE_SCREEN_WIDTH == 375.0f) ? YES : NO)

#define kYNPAGE_NAVHEIGHT (kYNPAGE_IS_IPHONE_X ? 88 : 64)

#define kYNPAGE_TABBARHEIGHT (kYNPAGE_IS_IPHONE_X ? 83 : 49)

#import "XYPageViewController.h"
#import "XYPageScrollView.h"
#import "XYPageConfigration.h"
#import "XYPageScrollMenuView.h"

@interface XYPageViewController ()<UIScrollViewDelegate,XYPageScrollMenuViewDelegate>
/// 标题数组
@property (nonatomic, strong) NSMutableArray * titlesM;

/// 页面ScrollView
@property (nonatomic, strong) XYPageScrollView * pageScrollView;

/// 配置信息
@property (nonatomic, strong) XYPageConfigration * config;

@property (nonatomic, strong) NSMutableDictionary *displayDictM;

@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) XYPageScrollMenuView * scrollMenuView;

@end

@implementation XYPageViewController


+ (instancetype)pageViewControllerWithControllers:(NSArray *)controllers
                                           titles:(NSArray *)titles
                                           config:(XYPageConfigration *)config{
    XYPageViewController *vc = [[self alloc] init];
    vc.controllersM = controllers.mutableCopy;
    vc.titlesM = titles.mutableCopy;
    vc.config = config ?: [XYPageConfigration defaultConfig];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];

    [self setupSubViews];
    
    self.pageIndex = 0;
    
}

- (void)setupSubViews {

    [self setupPageScrollMenuView];
    [self setupPageScrollView];
    [self initViewController];
}
- (void)initData {
    
    [self checkParams];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

/// 初始化ScrollView
- (void)setupPageScrollMenuView {
    
    
    
    [self initPagescrollMenuViewWithFrame:CGRectMake(0,[HiisIphoneXSeries isIPhoneXSeries]?84:64, self.config.menuWidth, self.config.menuHeight)];
}

/// 初始化PageScrollView
- (void)setupPageScrollView {
    
    [self.view addSubview:self.pageScrollView];    
    CGFloat navHeight = self.config.showNavigation ? kYNPAGE_NAVHEIGHT : 0;
    CGFloat tabHeight = self.config.showTabbar ? kYNPAGE_TABBARHEIGHT : 0;
    
    CGFloat contentHeight = kYNPAGE_SCREEN_HEIGHT - navHeight - tabHeight;
    
    self.pageScrollView.frame = CGRectMake(0, self.scrollMenuView.y + self.config.menuHeight, kYNPAGE_SCREEN_WIDTH, contentHeight);
    
    self.pageScrollView.contentSize = CGSizeMake(kYNPAGE_SCREEN_WIDTH * self.controllersM.count, contentHeight - self.config.menuHeight);
    
}

#pragma mark - 初始化PageScrollMenu
- (void)initPagescrollMenuViewWithFrame:(CGRect)frame {
    
    XYPageScrollMenuView *scrollMenuView = [XYPageScrollMenuView pagescrollMenuViewWithFrame:frame
                                                                                      titles:self.titlesM
                                                                                configration:self.config
                                                                                    delegate:self currentIndex:self.pageIndex];
    self.scrollMenuView = scrollMenuView;
    [self.view addSubview:self.scrollMenuView];
    
}


- (void)addPageChildControllersWithTitles:(NSArray *)titles
                              controllers:(NSArray *)controllers
                                    index:(NSInteger)index {
    index = index < 0 ? 0 : index;
    index = index > self.controllersM.count - 1 ? self.controllersM.count - 1 : index;
    
    if (titles.count == controllers.count && controllers.count > 0) {
        [self.controllersM addObjectsFromArray:controllers];
        [self.titlesM addObjectsFromArray:titles];
    }

    [self initViewController];
    
}

- (void)initViewController{
    for (int i =0; i<self.controllersM.count; i++) {
        UIViewController * vc = self.controllersM[i];
        vc.view.frame = CGRectMake(kYNPAGE_SCREEN_WIDTH * i, 0, self.pageScrollView.width, self.pageScrollView.height);
        [self.pageScrollView addSubview:vc.view];
    }
}

#pragma mark - YNPageScrollMenuViewDelegate
- (void)pagescrollMenuViewItemOnClick:(UILabel *)label index:(NSInteger)index {

    [self setSelectedPageIndex:index];
    if (self.selectItemBlock) {
        self.selectItemBlock(index);
    }
}

#pragma mark - Public Method
- (void)setSelectedPageIndex:(NSInteger)pageIndex {

//    if ( pageIndex == self.pageIndex) return;
    self.pageIndex = pageIndex;
    CGRect frame = CGRectMake(self.pageScrollView.width * pageIndex, 0, self.pageScrollView.width, self.pageScrollView.height);
    [self.pageScrollView scrollRectToVisible:frame animated:NO];
}

- (void)setIsScrollPageVC:(BOOL)isScrollPageVC
{
    _isScrollPageVC = isScrollPageVC;
    self.pageScrollView.scrollEnabled = isScrollPageVC;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    NSInteger p=scrollView.contentOffset.x/ self.pageScrollView.width;
    
    [self.scrollMenuView selectedItemIndex:p animated:YES];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [self.scrollMenuView adjustItemPositionWithCurrentIndex:self.pageIndex];
}

- (NSString *)titleWithIndex:(NSInteger)index {
    return  self.titlesM[index];
}


#pragma mark - Lazy Method
- (XYPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[XYPageScrollView alloc] init];
        _pageScrollView.showsVerticalScrollIndicator = NO;
        _pageScrollView.showsHorizontalScrollIndicator = NO;
        _pageScrollView.pagingEnabled = YES;
        _pageScrollView.bounces = NO;
        _pageScrollView.delegate = self;
        _pageScrollView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) {
            _pageScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _pageScrollView;
}

/// 检查参数
- (void)checkParams {
    
    NSAssert(self.controllersM.count != 0 || self.controllersM, @"ViewControllers`count is 0 or nil");
    
    NSAssert(self.titlesM.count != 0 || self.titlesM, @"TitleArray`count is 0 or nil,");
    
    NSAssert(self.controllersM.count == self.titlesM.count, @"ViewControllers`count is not equal titleArray!");
    
    BOOL isHasNotEqualTitle = YES;
    for (int i = 0; i < self.titlesM.count; i++) {
        for (int j = i + 1; j < self.titlesM.count; j++) {
            if (i != j && [self.titlesM[i] isEqualToString:self.titlesM[j]]) {
                isHasNotEqualTitle = NO;
                break;
            }
        }
    }
    NSAssert(isHasNotEqualTitle, @"TitleArray Not allow equal title.");
    
}
@end
