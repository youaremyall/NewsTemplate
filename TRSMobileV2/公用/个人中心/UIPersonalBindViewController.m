//
//  UIPersonalBindViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/7/19.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIPersonalBindViewController.h"
#import "Globals.h"

@interface UIPersonalBindViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __strong UITableView   *_tableView;
}

@end

@implementation UIPersonalBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUIControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {
    
    [self.navbar.barTitle setText:self.dict[@"title"] ];
    [self initUITableView];
}

- (void)initUITableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:[UIView new] ]; //隐藏底部多余的分割线
    [self.view addSubview:_tableView];
    _tableView.sd_layout
    .topSpaceToView(self.navbar, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
}

- (void)didSwitchValueChange:(UISwitch *)switch_ {

    NSDictionary *dict = valueForArrayFile(@"3party")[switch_.tag];
    SSDKPlatformType platform = [dict[@"platform"] integerValue];
    
    if([ShareSDK hasAuthorized:platform]) {
        [ShareSDK cancelAuthorize:platform];
    }
    else {
        [ShareSDK authorize:platform
                   settings:nil
             onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                 [_tableView reloadData];
             }];
    }
}

#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [valueForArrayFile(@"3party") count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryView = [[UISwitch alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [(UISwitch *)(cell.accessoryView) addTarget:self action:@selector(didSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView.tag = indexPath.row;
    }
    NSDictionary *dict = valueForArrayFile(@"3party")[indexPath.row];
    cell.indentationWidth = 20.0f;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = dict[@"title"];
    [(UISwitch *)(cell.accessoryView) setOn:[ShareSDK hasAuthorized:[dict[@"platform"] integerValue] ]  animated:YES];
    
    return cell;
}

@end
