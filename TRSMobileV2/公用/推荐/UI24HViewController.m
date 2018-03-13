//
//  UI24hNewsController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/1.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UI24HViewController.h"
#import "UIListViewController.h"
#import "Globals.h"

@interface UI24HViewController ()
{
    __strong UIListViewController  *_listVC;
}
@end

@implementation UI24HViewController

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
    
    [self setUINavbar];
    [self initUITableView];
}

- (void)setUINavbar {
    
    self.navbar.height = 190.0;
    [self.navbar.barBackground setImage:[UIImage imageNamed:@"normal.bundle/24小时背景.png"]];
    [self.navbar.barTitle setText:@"--聚集今日事实 浓缩新闻精华--"];
    [self.navbar.barTitle setFont:[UIFont systemFontOfSize:15.0] ];
    
    //24小时要闻
    UILabel *_label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, CGRectGetHeight(self.navbar.frame)/2.0 - 30.0 - 8.0, CGRectGetWidth(self.navbar.frame), 30.0);
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont systemFontOfSize:24.0];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"24小时要闻";
    [self.navbar addSubview:_label];
}

- (void)initUITableView {
    
    _listVC = [[UIListViewController alloc] init];
    _listVC.dict = self.dict;
    [self addChildViewController:_listVC];
    [self.view addSubview:_listVC.view];
    
    _listVC.view.sd_layout
    .topSpaceToView(self.navbar, 0)
    .bottomSpaceToView(self.view, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0);
}

@end
