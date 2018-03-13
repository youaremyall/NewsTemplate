//
//  TodayViewController.m
//  TRSMobileV2Today
//
//  Created by 廖靖宇 on 2017/2/31.
//  Copyright © 2017年  liaojingyu. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "NSDictionary+Extension.h"
#import "AFNetworking.h"
#import "SDAutoLayout.h"
#import "TodayCell.h"

const float cellTodayHeight = 100.0f;

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView   *tableView;
@property (strong, nonatomic) UIButton      *btnMore;
@property (strong, nonatomic) NSMutableArray *datasource;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 请求数据
    [self request];

    //
    [self initUIControls];

    // 设置widget展示视图的大小
    self.preferredContentSize = CGSizeMake(self.view.size.width, cellTodayHeight + 60.0);
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {

    if(activeDisplayMode == NCWidgetDisplayModeExpanded) {
        
        _btnMore.hidden = NO;
        _tableView.sd_layout.bottomSpaceToView(self.view, 60.0);
        [self setPreferredContentSize:CGSizeMake(self.view.size.width, _datasource.count * cellTodayHeight + 60.0)];
    }
    else {
        
        _btnMore.hidden = YES;
        _tableView.sd_layout.bottomSpaceToView(self.view, 0.0);
        [self setPreferredContentSize:CGSizeMake(self.view.size.width, cellTodayHeight)];
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    return  UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark -

- (void)initUIControls {

    _datasource = [NSMutableArray arrayWithCapacity:0];
    [self initUITableView];
    [self initUIMoreButton];
}

- (void)initUITableView {

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor lightGrayColor];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    _tableView.sd_layout.topSpaceToView(self.view, 0).leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.view, 60.0);
}

- (void)initUIMoreButton {

    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMore.layer.cornerRadius = 2.0f;
    _btnMore.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [_btnMore.titleLabel setFont:[UIFont systemFontOfSize:16.0] ];
    [_btnMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnMore setTitle:@"查看更多" forState:UIControlStateNormal];
    [_btnMore addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnMore];
    _btnMore.sd_layout.leftSpaceToView(self.view, 20).rightSpaceToView(self.view, 20).topSpaceToView(_tableView, 15.0).heightIs(30);
}

- (void)request {

    NSString *url = @"http://www.tibetapp.cn/zixun/toutiao/index.json";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", nil];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [_datasource removeAllObjects];
        
        //随机加载4条数据
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        [arr addObjectsFromArray:responseObject[@"topic_datas"]];
        [arr addObjectsFromArray:responseObject[@"datas"]];
        if(arr.count > 4) {
            NSInteger t = arr.count;
            NSInteger s = rand() % (t-1);
            if(s + 4 >= t) { s = t - 5;}
            [_datasource addObjectsFromArray:[arr subarrayWithRange:NSMakeRange(s, 4)] ];
        }
        else {
            [_datasource addObjectsFromArray:arr];
        }
        
        [_tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return cellTodayHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"TodayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if(!cell) {
        cell = [[NSClassFromString(identifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.frame = [tableView rectForRowAtIndexPath:indexPath];
    }
    ((TodayCell *)cell).dict = _datasource[indexPath.row];
    [((TodayCell *)cell) updateCell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //...do anything what you want.
    NSDictionary *dict = _datasource[indexPath.row];
    NSString *string = [NSString stringWithFormat:@"iOSWidgetApp://action=openNews"];
    string = [string stringByAppendingFormat:@"?type=%@&docid=%@&docurl=%@", dict[@"type"], dict[@"docid"], dict[@"docURL"] ];
    
    [self.extensionContext openURL:[NSURL URLWithString:string] completionHandler:nil];
}

- (void)more {
    
    [self.extensionContext openURL:[NSURL URLWithString:@"iOSWidgetApp://action=openAPP"] completionHandler:nil];
}

@end

