//
//  UINewsGridViewController.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/15.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UIGridViewController.h"
#import "UINewsAdsCell.h"
#import "Globals.h"

@interface UIGridViewController () <UIWaterflowLayoutDelegate, UICycleScrollViewDatasource> {
    
    NSString    *gridName;
}

@end

@implementation UIGridViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    gridName = [self getVCCellIdentifier:self.dict];
    [self.csView setDatasource:self];
    [(UIWaterflowLayout *)self.collectionViewLayout setDelegate:self];
    [self.collectionView registerClass:[NSClassFromString(gridName) class] forCellWithReuseIdentifier:gridName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWaterflowLayoutDelegate
- (NSInteger)columnCountInWaterflowLayout:(UIWaterflowLayout *)layout {

    BOOL isGrid = ([self.dict[@"channelType"] integerValue] == 5);
    return isGrid ? 3 : 2;
}

- (CGFloat)waterflowLayout:(UIWaterflowLayout *)layout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth {

    BOOL isGrid = ([self.dict[@"channelType"] integerValue] == 5);
    return itemWidth + (isGrid ? 0.0 : arc4random() % 100);
}

- (CGSize)sizeForHeaderInWaterflowLayout:(UIWaterflowLayout *)layout {

    return self.ads.count ? self.csView.size : CGSizeZero;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
        
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.datasource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *model = self.datasource[indexPath.row];

    id channelType = self.dict[@"channelType"];
    NSMutableDictionary * extsion_model = [NSMutableDictionary dictionaryWithCapacity:0];
    [extsion_model addEntriesFromDictionary:model];
    if(channelType) {
        [extsion_model setObject:channelType forKey:@"channelType"];
        [extsion_model setObject:channelType forKey:@"clickType"];
    }

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:gridName forIndexPath:indexPath];
    cell.dict = extsion_model;
    [cell updateCell];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *view = nil;
    if(kind == UICollectionElementKindSectionHeader && self.ads.count) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        if(view.subviews.count == 0) { //避免重复添加多个顶部大图视窗.
            [view addSubview:self.csView];
        }
        [self.csView reloadData];
    }
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //...do anything what you want.
    [self handleVCClickEvent:[collectionView cellForItemAtIndexPath:indexPath].dict ];
}

#pragma mark - UICycleScrollViewDatasource
- (NSInteger)numberOfPages:(UICycleScrollView *)csView {
    
    return self.ads.count;
}

- (NSDictionary *)pageAtIndex:(UICycleScrollView *)csView index:(NSInteger)index {
    
    return self.ads[index];
}

- (void)select:(UICycleScrollView *)csView index:(NSInteger)index {
    
    [self handleVCClickEvent:self.ads[index] ];
}

@end
