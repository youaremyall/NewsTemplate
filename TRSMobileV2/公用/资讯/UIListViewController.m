//
//  UINewsListViewController.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/4/28.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UIListViewController.h"
#import "UINewsAdsCell.h"
#import "UINewsVideoCell.h"
#import "XLVideoPlayer.h"
#import "Globals.h"

@interface UIListViewController () <UICycleScrollViewDatasource>

@property (strong, nonatomic) XLVideoPlayer *player;

@end

@implementation UIListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.csView setDatasource:self];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillDisappear:(BOOL)animated {

    [self.player destroyPlayer];
    self.player = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    self.tableView.tableHeaderView = self.ads.count ? self.csView : nil;
    if(self.ads.count) {[self.csView reloadData];}
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤2 * >>>>>>>>>>>>>>>>>>>>>>>>
    return [tableView cellHeightForIndexPath:indexPath cellContentViewWidth:[UIScreen mainScreen].bounds.size.width tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *model = self.datasource[indexPath.row];
    
    id channelType = self.dict[@"channelType"];
    NSMutableDictionary * extsion_model = [NSMutableDictionary dictionaryWithCapacity:0];
    [extsion_model addEntriesFromDictionary:model];
    if(channelType) {
        [extsion_model setObject:channelType forKey:@"channelType"];
        [extsion_model setObject:channelType forKey:@"clickType"];
    }
    
    NSString *identifier = [self getVCCellIdentifier:extsion_model];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if(!cell) {
        cell = [NSBundle instanceWithBundleNib:identifier]; //增加从NIB文件加载获取cell的能力.
        if(!cell) {
            cell = [[NSClassFromString(identifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    
    cell.dict = extsion_model;
    [cell updateCell];
    
    if([cell isKindOfClass:[NSClassFromString(@"UINewsVideoCell") class] ]) {
    
        __weak __typeof(cell) wcell = cell;
        cell.clickEvent = ^(NSDictionary *dict, NSInteger index) {
            
            [self.player destroyPlayer];
            self.player = nil;
            
            self.player = [[XLVideoPlayer alloc] init];
            self.player.videoUrl = @"http://baobab.wdjcdn.com/1456231710844S(24).mp4";
            [self.player playerBindTableView:tableView currentIndexPath:indexPath];
            self.player.frame = ((UINewsVideoCell *)wcell).imagePic1.bounds;
            [wcell.contentView addSubview:self.player];
            
            self.player.completedPlayingBlock = ^(XLVideoPlayer *player) {
                [player destroyPlayer];
                player = nil;
            };
            
            self.player.closeBlock = ^(XLVideoPlayer *player) {
                [player destroyPlayer];
                player = nil;
            };
            
            //上传文章属性统计数据
            [self syncDocAnalytics:[self.dict objectForVitualKey:@"docId"] action:actionTypePlay completion:^(BOOL succeeded, NSError * _Nullable error) {
            }];
        };
    }
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    //[cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    ///////////////////////////////////////////////////////////////////////
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //...do anything what you want.
    [self handleVCClickEvent:[tableView cellForRowAtIndexPath:indexPath].dict ];
}

#pragma makr -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [_player playerScrollIsSupportSmallWindowPlay:YES];
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
