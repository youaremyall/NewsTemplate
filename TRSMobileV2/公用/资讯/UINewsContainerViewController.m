//
//  UINewsContainerViewController.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/22.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UINewsContainerViewController.h"
#import "UIViewController+Extension.h"
#import "UIViewController+AssociatedObject.h"
#import "SVWebViewController.h"
#import "UINewsSubscribleItem.h"

@interface UINewsContainerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation UINewsContainerViewController

- (instancetype) init {

    _isFliter = YES;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    return [self initWithCollectionViewLayout:flowLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO; //解决cellForItemAtIndexPath不被调用问题.
    [self initUICollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void) initUICollectionView {
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
}

- (void) setChannels:(NSArray *)channels {
    
    _channels = channels;

    /*移除先前添加的视图和控制器*/
    for(UIViewController *vc in self.childViewControllers) {if(vc.viewIfLoaded) [vc.viewIfLoaded performSelector:@selector(removeFromSuperview)];}
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    /*添加新的视图和控制器*/
    NSInteger i = 0;
    for(NSDictionary *dict in _channels) {
        /*不过滤加载所有栏目，过滤仅加载已订阅的新闻子栏目*/
        if(!_isFliter || [dict[isChannelSubscrible] boolValue]) {
            
            NSString *className = [self getVCClassName:dict index:i];
            if([className isEqualToString:@"SVWebViewController"]) {
                SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:dict[@"url"] ];
                vc.isInset = YES;
                [self addChildViewController:vc];
            }
            else {
                UIViewController *vc = (UIViewController *)[[NSClassFromString(className) alloc] init];
                [vc setDict:dict];
                [self addChildViewController:vc];
            }
            ++i;
        }
    }

    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
}

- (void) setIndex:(NSInteger)index {

    if(index < 0 || index >= self.childViewControllers.count) return;
    
    [self.collectionView setContentOffset:CGPointMake(index * CGRectGetWidth(self.collectionView.frame), 0)];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];

    UIViewController *vc = self.childViewControllers[indexPath.item];
    vc.view.frame = cell.bounds;
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return collectionView.frame.size;
}

#pragma mark - UIScrollerViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger index = scrollView.contentOffset.x / self.view.bounds.size.width;
    if(_changeEvent) {_changeEvent(self.childViewControllers[index].dict, index);}
}

@end
