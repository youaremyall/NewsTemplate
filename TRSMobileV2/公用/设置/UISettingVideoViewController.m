//
//  UISettingVideoViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/18.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UISettingVideoViewController.h"
#import "Globals.h"

@interface UISettingVideoViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __strong UITableView    *_tableView;
}
@end

@implementation UISettingVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
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

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dict[@"options"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = self.dict[@"options"][indexPath.row];
    cell.accessoryType  = (indexPath.row == [[NSUserDefaults settingValueForType:SettingTypeAutoPlayVideo] integerValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isSame = (indexPath.row == [[NSUserDefaults settingValueForType:SettingTypeAutoPlayVideo] integerValue]);
    if(!isSame) {
        [NSUserDefaults setSettingValue:@(indexPath.row) type:SettingTypeAutoPlayVideo];
        if(self.clickEvent){self.clickEvent(nil, 1);}
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
