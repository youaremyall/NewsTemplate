//
//  UISettingViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UISettingViewController.h"
#import "UISettingFontSizeView.h"
#import "RNCachingURLProtocol.h"
#import "Globals.h"


@interface UISettingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __strong UITableView    *_tableView;
    __weak   UILabel        *_labelCache;
    BOOL                     _hasCache;
    NSUInteger               _sizeCache;
    NSArray                 *_arraySetting;
}
@end

@implementation UISettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initUIControls];
    [self performSelector:@selector(doCalculateCache) withObject:nil afterDelay:0.5f];
    addNotificationObserver(self, @selector(applicationWillEnterForeground:), UIApplicationWillEnterForegroundNotification, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {

    _arraySetting = valueForArrayFile(@"setting");
    
    [self.navbar.barTitle setText:@"设置"];
    [self initUITableView];
}

- (void)initUITableView {

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];    
    _tableView.sd_layout
    .topSpaceToView(self.navbar, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
}

#pragma mark -
- (void)switchValueChanged:(UISwitch *)_switch {

    NSInteger type = _switch.superview.tag;
    switch (type) {
        case 3: //仅WiFi网络加载图片
            [NSUserDefaults setSettingValue:@(_switch.on) type:SettingTypeOnlyWiFiLoadImages];
            break;
        case 4: //接收推送
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] ];
            break;
        }
        case 20://夜间模式
            [NSUserDefaults setSettingValue:@(_switch.on) type:SettingTypeNightMode];
            break;
            
        default:
            break;
    }
}

- (void)didSettingCell:(NSDictionary *)dict {

    NSInteger type = [dict[@"type"] integerValue];
    switch (type) {
        case 0: //字体设置
        case 2: //自动播放视频
        {
            NSString *className;
            if(type == 0) className = @"UISettingFontViewController";
            if(type == 2) className = @"UISettingVideoViewController";
            
            if(className) {
                UIViewController *vc = [[NSClassFromString(className) alloc] init];
                vc.dict = dict;
                vc.clickEvent = ^(NSDictionary *dict, NSInteger index) {
                    [_tableView reloadData];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case 1: //正文字号
        {
            [GDelegate.navTab setCanDargBack:NO];
            [GDelegate.vcDrawer setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionHorizontal];
            [UISettingFontSizeView showInView:self.view
                                  changeBlock:^(NSInteger fontSize) {
                                      [_tableView reloadData];
                                  }
                                 dismissBlock:^{
                                     [GDelegate.navTab setCanDargBack:YES];
                                     [GDelegate.vcDrawer setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionHorizontal];
                                 }
            ];
            break;
        }
        case 21://扫一扫
        {
            UIViewController *vc = [[NSClassFromString(@"QRViewController") alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [nav setNavigationBarHidden:YES animated:YES];
            [self presentViewController:nav animated:YES completion:^(){}];
            break;
        }
        case 22://清理缓存
            if(_hasCache) {[self doClearCache];}
            break;
        case 40://我要评分
            [[iRate sharedInstance] openRatingsPageInAppStore];
            break;
        case 41://关于我们
        {
            SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:valueForDictionaryFile(@"website")[@"AboutUsUrl"] ];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        default:
            break;
    }
}

- (void)doCalculateCache {
    
    _labelCache.text = @"计算中...";
    _sizeCache = 0;
    _sizeCache += [[SDImageCache sharedImageCache] getSize];
    _sizeCache += [RNCachingURLProtocol getSize];
    
    _hasCache = (_sizeCache >= 1024); //修正清除缓存显示0.0M，应浮点数取1位会自动四舍五入计算
    [_labelCache setText:(_hasCache ? [NSString stringWithFormat:@"%0.2fM", _sizeCache/(1024.0*1024.0)] : nil) ];
}

- (void)doClearCache {

    [SVProgressHUD showWithStatus:@"清理中..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //执行底层清理工作
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^(){}];
        [RNCachingURLProtocol clearAllRNCaches];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        //界面操作
        _hasCache = NO; //清除缓存后重置相关的标识和数值.
        [_labelCache setText:nil];
        [SVProgressHUD showSuccessWithStatus:@"清除成功"];
    });
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _arraySetting.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_arraySetting[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"UISettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        UISwitch *_switch = [[UISwitch alloc] init];
        _switch.hidden = YES;
        _switch.tag = 0x1001;
        [_switch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:_switch];
        
        _switch.sd_layout.centerYEqualToView(cell.contentView).rightSpaceToView(cell.contentView, (isiPad() ? 44.0 : 20.0)).widthIs(51.0f).heightIs(31.0f);
    }
    
    cell.indentationWidth = 20.0f;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    
    NSDictionary *dict = _arraySetting[indexPath.section][indexPath.row];
    NSInteger type = [dict[@"type"] integerValue];
    cell.textLabel.text = dict[@"title"];
    cell.contentView.tag = type;
    
    UISwitch *_switch = [cell.contentView viewWithTag:0x1001];
    switch (type) {
            
        case 0: //字体设置
        {
            NSString *fontPath = [NSUserDefaults settingValueForType:SettingTypeFontFamily];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = ((fontPath.pathExtension == nil) ? fontPath : fontPath.lastPathComponent.stringByDeletingPathExtension);
            [_switch setHidden:YES];
            break;
        }
            
        case 1: //正文字号
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSInteger fontSize = [[NSUserDefaults settingValueForType:SettingTypeFontSize] integerValue];
            cell.detailTextLabel.text = dict[@"options"][fontSize];
            [_switch setHidden:YES];
            break;
            
        case 2: //自动播放视频
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSInteger mode = [[NSUserDefaults settingValueForType:SettingTypeAutoPlayVideo] integerValue];
            cell.detailTextLabel.text = dict[@"options"][mode];
            [_switch setHidden:YES];
            break;
            
        case 3: //仅WiFi网络加载图片，默认开启
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = nil;
            [_switch setHidden:NO];
            [_switch setOn:[[NSUserDefaults settingValueForType:SettingTypeOnlyWiFiLoadImages] boolValue] animated:NO];
            break;
            
        case 4: //接收推送，默认开启
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = nil;
            BOOL isRegisteredForRemoteNotifications = [UIApplication sharedApplication].currentUserNotificationSettings.types;
            [_switch setHidden:NO];
            [_switch setOn:isRegisteredForRemoteNotifications animated:NO];
            break;
            
        case 20: //夜间模式
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = nil;
            [_switch setHidden:NO];
            [_switch setOn:[[NSUserDefaults settingValueForType:SettingTypeNightMode] boolValue] animated:NO];
            break;
            
        case 22: //清理缓存
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.textColor = [UIColor redColor];
            _labelCache = cell.detailTextLabel;
            cell.detailTextLabel.text = (_hasCache ? [NSString stringWithFormat:@"%0.2fM", _sizeCache/(1024.0*1024.0)] : nil);
            [_switch setHidden:YES];
            break;
            
        case 21: //扫一扫
        case 40: //我要评分
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
            [_switch setHidden:YES];
            break;
            
        case 41: //关于我们
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
            [_switch setHidden:YES];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = _arraySetting[indexPath.section][indexPath.row];
    [self didSettingCell:dict];
}

@end
