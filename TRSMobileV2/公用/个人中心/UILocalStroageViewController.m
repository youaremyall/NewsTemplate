//
//  UIMyHistoryViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UILocalStroageViewController.h"
#import "UIListViewController.h"
#import "Globals.h"

@interface UILocalStroageViewController () <UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>
{
    __strong UIListViewController  *_listVC;
    NSUInteger            _total;
}

/**
 * @brief 数据类型标识
 */
@property (assign, nonatomic)   serviceType    type;

@end

@implementation UILocalStroageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIControls];
    addNotificationObserver(self, @selector(favoriteDidChange:), didFavoriteChangeNotification, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {
    
    _type = ([self.dict[@"type"] integerValue]  == 0 ? serviceTypeHistory : serviceTypeFavorite);
    
    [self.navbar.barTitle setText:self.dict[@"title"] ];
    [self.navbar.barRight setTitle:@"编辑" forState:UIControlStateNormal];

    [self initUITableView];
    [self handleEventBlocks];
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

- (void) handleEventBlocks {

    __weak __typeof(self) wself = self;
    __weak __typeof(self.navbar) wnavbar = self.navbar;
    __weak __typeof(_listVC) wlistVC = _listVC;

    self.navbar.clickEvent = ^(NSDictionary *dict , NSInteger index) {
        switch (index) {
            case 0:
                [wself.navigationController popViewControllerAnimated:YES];
                break;
                
            case 1:
            {
                [wlistVC.tableView setEditing:!wlistVC.tableView.editing animated:YES];
                [wnavbar.barRight setTitle:(wlistVC.tableView.editing ? @"取消" : @"编辑") forState:UIControlStateNormal];
                break;
            }
                
            default:
                break;
        }
    };

}

#pragma mark -
- (void)request {

    NSArray *response = [StroageService valuesForType:_type
                                               offset:(_listVC.isRefresh ? 0 : _listVC.datasource.count)
                                                limit:20];
    
    [self responseHandler:YES response:response];
}

- (void)responseHandler:(BOOL)success response:(id)response {

    if(success) {
        BOOL isKeyValue = [response isKindOfClass:[NSDictionary class]];
        if(_listVC.isRefresh) {
            _total = [StroageService totalValuesForType:_type];
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
- (void)favoriteDidChange:(NSNotification *)notification {

    if(_type == serviceTypeFavorite) {
        [self request];
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
    
    NSDictionary *model =  [(MagicalRecordCache *)_listVC.datasource[indexPath.row] value][@"content"];
    
    /*替换显示时间为记录时间*/
    NSTimeInterval timeInterval = [(MagicalRecordCache *)_listVC.datasource[indexPath.row] timestamp];
    NSMutableDictionary *extension_model = [NSMutableDictionary dictionaryWithDictionary:model];
    [extension_model setObject:[NSDate dateStringByTimestamp:timeInterval format:@"yyyy-MM-dd HH:mm:ss"] forKey:@"PubDate"];
    
    /*加载cell显示*/
    NSString *identifier = [self getVCCellIdentifier:extension_model];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if(!cell) {
        cell = [NSBundle instanceWithBundleNib:identifier]; //增加从NIB文件加载获取cell的能力.
        if(!cell) {
            cell = [[NSClassFromString(identifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        //configure right buttons
        ((MGSwipeTableCell*)cell).delegate = self;
    }
    
    cell.dict = extension_model;
    [cell updateCell];
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    //[cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    ///////////////////////////////////////////////////////////////////////
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self executeReallyDeleteEvent:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self handleVCClickEvent:[tableView cellForRowAtIndexPath:indexPath].dict ];
}

#pragma mark -MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    if(direction == MGSwipeDirectionRightToLeft) {
        
        NSMutableArray * result = [NSMutableArray array];
        NSString* titles[1] = {@"删除"};
        UIColor * colors[1] = {[UIColor redColor]};
        for (int i = 0; i < 1; ++i)
        {
            MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
                return NO; //Don't autohide in delete button to improve delete expansion animation
            }];
            [result addObject:button];
        }
        return result;
    }
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        //delete button
        NSIndexPath *path = [_listVC.tableView indexPathForCell:cell];
        [self executeReallyDeleteEvent:path];
        
        return NO; //Don't autohide to improve delete expansion animation
    }
    
    return YES;
}

- (void)executeReallyDeleteEvent:(NSIndexPath *)indexPath {

    [StroageService removeValuesForArray:@[_listVC.datasource[indexPath.row] ] ];
    [_listVC.datasource removeObjectAtIndex:indexPath.row];
    [_listVC.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
