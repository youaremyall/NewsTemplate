//
//  UIPersonalSexViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIPersonalSexViewController.h"
#import "Globals.h"

@interface UIPersonalSexViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __strong UITableView   *_tableView;
}

@end

@implementation UIPersonalSexViewController

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

#pragma mark -
- (void)doSave:(NSInteger)sex {
    
    AVUser *user = [AVUser currentUser];
    [user setObject:@(sex) forKey:@"sex"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            if(self.clickEvent) {self.clickEvent(nil, 1);}
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.indentationWidth = 20.0f;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = (indexPath.row == 0 ? @"男" : @"女");
    cell.accessoryType  = (indexPath.row == [self.dict[@"sex"] integerValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == [self.dict[@"sex"] integerValue]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self doSave:indexPath.row];
    }
}

@end
