//
//  UIMyMessageViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIMyMessageViewController.h"
#import "UIListViewController.h"
#import "Globals.h"

@interface UIMyMessageViewController () <UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>
{
    __strong UIListViewController  *_listVC;
    
    NSUInteger            _total;
}
@end

@implementation UIMyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) initUIControls {
    
    [self.navbar.barTitle setText:(@"我的消息")];
    [self initUITableView];
}

- (void)initUITableView {
    
    __weak typeof(self) wself = self;
    _listVC = [[UIListViewController alloc] init];
    _listVC.dict = self.dict;
    _listVC.requestBlock = ^(){[wself request];};
    _listVC.tableView.dataSource = self;
    _listVC.tableView.delegate = self;
    _listVC.tableView.backgroundColor = [UIColor clearColor];
    [self addChildViewController:_listVC];
    [self.view addSubview:_listVC.view];
    
    _listVC.view.sd_layout
    .topSpaceToView(self.navbar, 0)
    .bottomSpaceToView(self.view, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0);
}

#pragma mark -
- (void)request {

    NSMutableArray *response = [NSMutableArray arrayWithCapacity:0];
    for(NSInteger i = 0; i < 20; i++) {
        [response addObject:@{@"content" : @"据香港( 路线 )《文汇报》援引外媒报道，美国黄石国家公园一座沉睡了64万年的超级火山，于过去7年来以破纪录速度隆起，恐怕会发生史上第4次爆发。若真的爆发，厚达30厘米的火山灰将笼罩1600平方公里的区域，届时美国将有2/3地区无法居住，航空交通瘫痪，数百万计居民无家可归，植物也可能消失殆尽。",
                              @"date" : @"2016-06-30 10:50:30",
                              @"type" : @"系统公告",
                              @"unRead" : @(1)}];
    }
    
    [self responseHandler:YES response:response];
}

- (void)responseHandler:(BOOL)success response:(id)response {
    
    if(success) {
        BOOL isKeyValue = [response isKindOfClass:[NSDictionary class]];
        if(_listVC.isRefresh) {
            [_listVC.datasource removeAllObjects];
        }
        
        if(isKeyValue) {
            [_listVC.datasource addObjectsFromArray:response[@"response"]];
        }
        else {
            [_listVC.datasource addObjectsFromArray:response];
        }
        
        [_listVC.tableView performSelector:@selector(reloadData)];
    }
    
    [_listVC.tableView.mj_header performSelector:@selector(endRefreshing)];
    if(_listVC.datasource.count < _total) {
        [_listVC.tableView.mj_footer performSelector:@selector(endRefreshing)];
    }
    else {
        [_listVC.tableView.mj_footer performSelector:@selector(endRefreshingWithNoMoreData)];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _listVC.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤2 * >>>>>>>>>>>>>>>>>>>>>>>>
    return [tableView cellHeightForIndexPath:indexPath cellContentViewWidth:[UIScreen mainScreen].bounds.size.width tableView:tableView];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"UIMyMessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if(!cell) {
        cell = [NSBundle instanceWithBundleNib:identifier]; //增加从NIB文件加载获取cell的能力.
        if(!cell) {
            cell = [[NSClassFromString(identifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    
    cell.dict = _listVC.datasource[indexPath.row];
    [cell updateCell];
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    //[cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    ///////////////////////////////////////////////////////////////////////
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
