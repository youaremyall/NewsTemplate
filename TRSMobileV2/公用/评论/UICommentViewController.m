//
//  UICommentViewController.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UICommentViewController.h"
#import "UIRefreshTableViewController.h"
#import "UICommentCell.h"
#import "UICommentPostView.h"
#import "Globals.h"

@interface UICommentViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __strong UIToolbarView      *_toolbar;
    __strong UIRefreshTableViewController  *_listVC;
}
@end

@implementation UICommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIControls];
    [self getMyCommentTotal];
    addNotificationObserver(self, @selector(commentDidPost:), didCommentPostNotification, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) initUIControls {
    
    [self.navbar.barTitle setText:(!_isMyComment ? @"评论" :  @"我的评论")];

    [self initUIToolbar];
    [self initUITableView];
}

- (void) initUIToolbar {
    
    if(_isMyComment) return;
    
    CGRect frame = CGRectMake(0, self.view.height -  kHeightUIToolbar, self.view.width, kHeightUIToolbar);
    _toolbar = [[UIToolbarView alloc] initWithFrame:frame];
    _toolbar.onlyHasPost = YES;
    _toolbar.vc = self;
    [_toolbar loadProperty];
    [self.view addSubview:_toolbar];
}

- (void)initUITableView {

    __weak typeof(self) wself = self;
    _listVC = [[UIRefreshTableViewController alloc] init];
    _listVC.dict = self.dict;
    _listVC.requestBlock = ^() {[wself request];};
    _listVC.tableView.dataSource = self;
    _listVC.tableView.delegate = self;
    _listVC.tableView.tableFooterView = [UIView new]; //隐藏底部多余的分割线
    [self addChildViewController:_listVC];
    [self.view addSubview:_listVC.view];
    
    _listVC.view.sd_layout
    .topSpaceToView(self.navbar, 0)
    .bottomSpaceToView(!_isMyComment ? _toolbar : self.view, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0);
}

#pragma mark -

- (void)getMyCommentTotal {

    if(!_isMyComment) return;
    
    AVQuery *query = [AVQuery queryWithClassName:@"Comment"];
    [query whereKey:@"user" equalTo:[AVUser currentUser] ];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        _total = number;
    }];
}

- (void)request {
    
    AVQuery *query = [AVQuery queryWithClassName:@"Comment"];
    if(!_isMyComment)
        [query whereKey:@"docId" equalTo:[self.dict objectForVitualKey:@"docId"]];
    else
        [query whereKey:@"user" equalTo:[AVUser currentUser] ];
    [query whereKey:@"status" notEqualTo:@(commentStatusReview)]; //增加对status审核状态的判断
    [query includeKey:@"user"];
    query.limit = 20; //限定返回数据
    query.skip  = _listVC.isRefresh ? 0: _listVC.datasource.count; //跳过数量
    [query orderByDescending:@"createdAt"]; //按时间降序排列
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error) {
            [self responseHandler:YES response:objects];
        }
        else  {
            [self responseHandler:NO response:objects];
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    }];
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

#pragma mark - Notification
- (void)commentDidPost:(NSNotification *)notification {

    ++_total;
    [_listVC.tableView.mj_header performSelector:@selector(beginRefreshing)];
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
    
    static NSString *identifier = @"UICommentCell";
    UICommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if(!cell) {
        cell = [NSBundle instanceWithBundleNib:identifier]; //增加从NIB文件加载获取cell的能力.
        if(!cell) {
            cell = [[NSClassFromString(identifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    
    cell.isMyComment = _isMyComment;
    cell.avObject = _listVC.datasource[indexPath.row];
    [cell updateCell];
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    //[cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    ///////////////////////////////////////////////////////////////////////
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //...do anything what you want.
    if(_isMyComment) {
        NSDictionary *dict = ((UICommentCell *)[tableView cellForRowAtIndexPath:indexPath]).avObject[@"docValue"];
        [self handleVCClickEvent:dict];
    }
}

@end
