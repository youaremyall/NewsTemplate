//
//  UIPersonalCenterViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/8.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIPersonalCenterViewController.h"
#import "UILoginViewController.h"
#import "UICommentViewController.h"
#import "Globals.h"

@interface UIPersonalCenterViewController () <UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView     *_tableView;
    
    __weak IBOutlet UIView          *_viewPersonal;
    __weak IBOutlet UIView          *_viewPersonalBar;
    
    __weak IBOutlet UIButton        *_buttonSetting;
    __weak IBOutlet UIImageView     *_imagePersonalBG;
    __weak IBOutlet UIImageView     *_imageAvatar;
    __weak IBOutlet UILabel         *_labelName;
    
    NSArray                         *_arrayPersonalCenter;
}
@end

@implementation UIPersonalCenterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIControls];
    [self getPersonalInfo:nil];
    addNotificationObserver(self, @selector(getPersonalInfo:), didPersonalInfoChangeNotification, nil);
}

- (void)viewWillAppear:(BOOL)animated {

    [_tableView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {

    _arrayPersonalCenter = valueForDictionaryFile(@"personal")[@"center"];
    
    //用户个人信息
    _imagePersonalBG.clipsToBounds = YES;
    [_imagePersonalBG setContentMode:UIViewContentModeTopLeft];
    [_imagePersonalBG setUIImageWithURL:UIGlobalImageBackground placeholderImage:nil completed:nil];
    [_imageAvatar setCornerWithRadius:CGRectGetHeight(_imageAvatar.frame)/2.0];
    [_imageAvatar addTapGesture:self selector:@selector(didAvatarSelect:)];
    [_labelName setFont:[UIFont systemFontOfSize:17.0] ];
    [_buttonSetting setImage:[UIImage imageNamed:@"normal.bundle/导航_设置.png"] forState:UIControlStateNormal];
    
    //用户操作栏
    [self initUIPersonalBar];
    
    //下面的列表
    _tableView.tableHeaderView = _viewPersonal;
    [_tableView setTableFooterView:[UIView new] ]; //隐藏底部多余的分割线
}

- (void)initUIPersonalBar {

    NSInteger enable = (isMyReadingEnable ? 0 : 1);
    NSInteger total = 3 - enable;
    CGFloat x = 0.0f; CGFloat margin = 1.0f;
    CGFloat w = (CGRectGetWidth([UIScreen mainScreen].bounds) - (total - 1) * margin) / total;
    UIImage *highlight = [UIImage imageWithColor:[UIColor colorWithRGB:0xd9d9d9] cornerRadius:0.0];
    
    for(NSInteger i = 0; i < total; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, 0, w, CGRectGetHeight(_viewPersonalBar.frame));
        button.backgroundColor = [UIColor whiteColor];
        button.tag = [_arrayPersonalCenter[(i + enable)][@"type"] integerValue];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:_arrayPersonalCenter[(i + enable)][@"title"] forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(32, 0, 0, 0)];
        [button setBackgroundImage:highlight forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
        [button addDidFontChangeObserver]; //wujianjun 2016-06-18 add for 适应字体设置更改
        [_viewPersonalBar addSubview:button];
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"normal.bundle/个人中心_%@.png", button.titleLabel.text]];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        icon.center = CGPointMake(button.center.x, button.center.y - 12.0);
        icon.image  = [image colorImage:[UIColor colorWithRGB:UIColorThemeDefault]];
        [_viewPersonalBar addSubview:icon];
        
        x += (w + margin);
    }
}

- (void)getPersonalInfo:(NSNotification *)notification {
    
    /*获取当前用户*/
    AVUser *user = [AVUser currentUser];
    UIImage *_avatar = [UIImage imageNamed:@"normal.bundle/用户头像.png"];
    if(user) {
        
        NSString *avatar = [user objectForKey:@"avatar"];
        if(avatar) {
            [_imageAvatar setUIImageWithURL:[user objectForKey:@"avatar"] placeholderImage:_avatar completed:nil];
        }
        else {
            [_imageAvatar setImage:_avatar];
        }
        
        NSString *nickname = [user objectForKey:@"nickname"];
        [_labelName setText:(nickname ? nickname : user.username)];
    }
    else {
        [_imageAvatar setImage:_avatar];
        [_labelName setText:@"立即登录"];
    }
    
    /*绑定与解绑用户*/
    if(notification && notification.userInfo) {
        [JPUSHService setTags:nil completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        } seq:0];
        [JPUSHService setAlias:[AVUser currentUser].objectId completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        } seq:1];
    }
}

#pragma mark -
- (IBAction)didButtonSelect:(id)sender {

    NSInteger tag = [(UIButton *)sender tag];
    [self handleEventBlocks:tag];
}

- (void)didAvatarSelect:(id)sender {

    [self handleEventBlocks:101];
}

- (void)handleEventBlocks:(NSInteger)index {

    switch (index) {
        case 101: //我的头像
        case 2: //我的评论
        case 3: //我的消息
        {
            NSString *className = (![AVUser currentUser]) ? @"UILoginViewController" : nil;
            if(className == nil) {
                if(index == 101)    className = @"UIPersonalProfileViewController";
                else if(index == 2) className = @"UICommentViewController";
                else if(index == 3) className = @"UIMyMessageViewController";
            }
            
            id vc = [[NSClassFromString(className) alloc] init];
            if(index == 2 && [className isEqualToString:@"UICommentViewController"]) {
                ((UICommentViewController *)vc).isMyComment = YES;
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 100: //设置
        case 0: //我的阅读
        case 1: //我的收藏
        case 5: //意见反馈
        {
            NSString *className = nil;
            if(index == 100)    className = @"UISettingViewController";
            else if(index == 0) className = @"UILocalStroageViewController";
            else if(index == 1) className = @"UILocalStroageViewController";
            else if(index == 5) className = @"UIFeedbackViewController";
            
            if(className) {
                id vc = [[NSClassFromString(className) alloc] init];
                if(index == 0 || index == 1) {
                    ((UIViewController *)vc).dict = _arrayPersonalCenter[index];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case 4: //离线阅读
            [UIOfflineProgressView show];
            break;
        case 6: //邀请朋友
            [ShareSDK showShareActionSheet:_arrayPersonalCenter[index][@"share"] inView:_tableView.visibleCells.lastObject.imageView];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return (_arrayPersonalCenter.count - 3);
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
    cell.accessoryType = (indexPath.row % 2 == 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = _arrayPersonalCenter[(indexPath.row + 3)][@"title"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"normal.bundle/个人中心_%@.png", cell.textLabel.text]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self handleEventBlocks:[_arrayPersonalCenter[(indexPath.row + 3)][@"type"] integerValue] ];
}

@end
