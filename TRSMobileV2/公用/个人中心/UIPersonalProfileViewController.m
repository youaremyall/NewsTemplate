//
//  UIPersonalProfileViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIPersonalProfileViewController.h"
#import "UILoginViewController.h"
#import "Globals.h"

@interface UIPersonalProfileViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIView      *_viewPersonal;
    __weak IBOutlet UIView      *_viewLogout;

    __weak IBOutlet UIButton    *_buttonBack;
    __weak IBOutlet UIButton    *_buttonLogout;

    __weak IBOutlet UIImageView *_imagePersonalBG;
    __weak IBOutlet UIImageView *_imageAvatar;
    __weak IBOutlet UILabel     *_labelName;
    
    NSArray                     *_arrayPersonalProfile;
}

@end

@implementation UIPersonalProfileViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUIControls];
    [self getPersonalInfo];
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

    _arrayPersonalProfile = valueForDictionaryFile(@"personal")[@"profile"];
    
    //用户头像
    _imagePersonalBG.clipsToBounds = YES;
    [_imagePersonalBG setUIImageWithURL:UIGlobalImageBackground placeholderImage:nil completed:nil];
    [_imageAvatar setCornerWithRadius:CGRectGetHeight(_imageAvatar.frame)/2.0];
    [_imageAvatar addTapGesture:self selector:@selector(didAvatarSelect:)];
    [_labelName setFont:[UIFont systemFontOfSize:17.0] ];
    [_buttonBack  setImage:[UIImage imageNamed:@"normal.bundle/导航_返回.png"] forState:UIControlStateNormal];
    
    //注销登录
    _buttonLogout.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_buttonLogout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonLogout setCornerWithRadius:CGRectGetHeight(_buttonLogout.frame)/2.0];
    [_buttonLogout setBackgroundImage:[UIImage imageWithColor:[UIColor redColor] cornerRadius:0] forState:UIControlStateNormal];
    [_buttonLogout setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor] cornerRadius:0] forState:UIControlStateHighlighted];
    
    //列表显示
    _tableView.tableHeaderView = _viewPersonal;
    _tableView.tableFooterView = _viewLogout;
}

- (void)getPersonalInfo {

    NSString *avatar = [[AVUser currentUser] objectForKey:@"avatar"];
    UIImage *_avatar = [UIImage imageNamed:@"normal.bundle/用户头像.png"];
    if(avatar) {
        [_imageAvatar setUIImageWithURL:avatar placeholderImage:_avatar completed:nil];
    }
    else {
        [_imageAvatar setImage:_avatar ];
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
        case 0: //昵称
        case 2: //签名
        {
            AVUser *user = [AVUser currentUser];
            NSString *text = @"";
            if(index == 0 && [user objectForKey:@"nickname"]) {
                text = [user objectForKey:@"nickname"];
            }
            else if(index == 2 && [user objectForKey:@"signature"]) {
                text = [user objectForKey:@"signature"];
            }
            
            UIViewController *vc = [[NSClassFromString(@"UIPersonalEditViewController") alloc] init];
            vc.dict = @{@"title" : _arrayPersonalProfile[index][@"title"], @"text"  : text, @"type"  : @(index)};
            vc.clickEvent = ^(NSDictionary *dict, NSInteger _index){
                if(index == 0) { //更新个人中心的昵称
                    postNotificationName(didPersonalInfoChangeNotification, nil, nil);
                }
                [_tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: //性别
        {
            NSInteger sex = 0;
            id value = [[AVUser currentUser] objectForKey:@"sex"];
            if(value) {sex = [value integerValue];}
            if(sex > 2) {sex = 0;}
            
            UIViewController *vc = [[NSClassFromString(@"UIPersonalSexViewController") alloc] init];
            vc.dict = @{@"title" : _arrayPersonalProfile[index][@"title"], @"sex" : @(sex)};
            vc.clickEvent = vc.clickEvent = ^(NSDictionary *dict, NSInteger _index) {
                [_tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3: //手机号码
            break;
        case 4: //账号绑定
        {
            UIViewController *vc = [[NSClassFromString(@"UIPersonalBindViewController") alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 100: //返回
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 101://修改头像
        {
            LCActionSheet *sheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                if(buttonIndex) {
                    [self selectPhoto:(buttonIndex == 1)];
                }
            } otherButtonTitles:@"拍照", @"从相册上传", nil];
            [sheet show];
            break;
        }
        case 102://退出登录
        {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认退出登录?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [vc addAction:[UIAlertAction actionWithTitle:@"退出" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
                [self logout];
            }]];
            [self presentViewController:vc animated:YES completion:^(void){}];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -
- (void)selectPhoto:(BOOL)album {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES; //可编辑
    //判断是否可以打开照相机
    if (!album && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else { //否则打开照片库
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)uploadAvatar:(UIImage *)image {

    [SVProgressHUD showWithStatus:@"上传头像中..."];
    AVFile *file = [AVFile fileWithName:[NSString stringWithFormat:@"%@_avatar.jpg", [AVUser currentUser].username ]
                                   data:UIImageJPEGRepresentation(image, 1.0)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"文件地址 : %@", file.url);
        if(succeeded) {
            AVUser *user = [AVUser currentUser];
            [user setObject:file.url forKey:@"avatar"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"上传头像成功"];
                    postNotificationName(didPersonalInfoChangeNotification, nil, nil);
                }
                else {
                    [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                }
            }];
        }
        else {
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    } progressBlock:^(NSInteger percentDone) {
        [SVProgressHUD showProgress:(percentDone / 100) status:@"上传头像中..."];
    }];
}

- (void)logout {

    [SVProgressHUD showWithStatus:@"退出登录中..."];    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [AVUser logOut];
        if(self.logoutBlock){self.logoutBlock(YES);}
        postNotificationName(didPersonalInfoChangeNotification, nil, @{@"isLogin" : @(0)});
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                                   [_imageAvatar setImage:image];
                                   [self uploadAvatar:image];
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                               }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _arrayPersonalProfile.count;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = _arrayPersonalProfile[indexPath.row][@"title"];
    
    AVUser *user = [AVUser currentUser];
    NSInteger type = [_arrayPersonalProfile[indexPath.row][@"type"] integerValue];
    switch (type) {
        case 0: //昵称
            cell.detailTextLabel.text = [user objectForKey:@"nickname"] ? [user objectForKey:@"nickname"] : user.username;
            break;
        case 1: //性别
        {
            NSInteger sex = 0;
            id value = [user objectForKey:@"sex"];
            if(value) {sex = [value integerValue];}
            if(sex > 2) {sex = 0;}
            cell.detailTextLabel.text = @[@"男", @"女", @"未知"][sex];
            break;
        }
        case 2: //签名
            cell.detailTextLabel.text = [user objectForKey:@"signature"] ? [user objectForKey:@"signature"] : @"这个人很懒，什么也没有留下";
            break;
        case 3: //手机号码
            cell.detailTextLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.text = user.mobilePhoneNumber ? user.mobilePhoneNumber : @"绑定手机号";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self handleEventBlocks:[_arrayPersonalProfile[indexPath.row][@"type"] integerValue] ];
}

@end
