//
//  UILoginViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UILoginViewController.h"
#import "AVOSCloudSNS.h"
#import "AVUser+SNS.h"
#import "Globals.h"

@interface UILoginViewController () <UITextFieldDelegate>
{
    /*整体背景图*/
    __weak IBOutlet UIImageView *_imageAllBG;
    
    /*导航条背景*/
    __weak IBOutlet UIImageView *_imageNavBG;
    
    /*导航条左侧图标*/
    __weak IBOutlet UIButton *_buttonNavLeft;
    
    /*导航条标题*/
    __weak IBOutlet UILabel *_labelTitle;
    
    /*用户名图标*/
    __weak IBOutlet UIImageView *_iconUsername;
    
    /*用户名输入框*/
    __weak IBOutlet UITextField *_textFieldUsername;
    
    /*分割线1*/
    __weak IBOutlet UIView *_viewLine1;
    
    /*密码图标*/
    __weak IBOutlet UIImageView *_iconPassword;
    
    /*密码输入框*/
    __weak IBOutlet UITextField *_textFieldPassword;
    
    /*记住用户*/
    __weak IBOutlet UIButton *_buttonKeep;
    
    /*忘记密码*/
    __weak IBOutlet UIButton *_buttonForget;
    
    /*登录*/
    __weak IBOutlet UIButton *_buttonLogin;
    
    /*第三方登录文本*/
    __weak IBOutlet UILabel *_label3Login;
    
    /*第三方登录文本分割线*/
    __weak IBOutlet UIView *_viewLine2;
    
    /*微信*/
    __weak IBOutlet UIButton *_buttonWeiXin;
    
    /*QQ*/
    __weak IBOutlet UIButton *_buttonQQ;
    
    /*新浪微博*/
    __weak IBOutlet UIButton *_buttonSina;
    
    /*还没有账号? 注册*/
    __weak IBOutlet UIButton *_buttonRegister;
}

@property (copy, nonatomic) void (^completion)(BOOL success);

@end

@implementation UILoginViewController

/**
 * @brief 显示登录页面
 * @param parent : 显示登录页面的视图
 * @param completion : 用户登录回调
 * @return 无
 */
+ (void)showLoginInVC:(UIViewController * _Nonnull)parent completion:(void (^ _Nullable)(BOOL success))completion {

    UILoginViewController *vc = [[UILoginViewController alloc] init];
    vc.completion = completion;
    UIAnimationNavigationController *nav = [[UIAnimationNavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES animated:NO];
    [parent presentViewController:nav animated:YES completion:^{}];
}

#pragma mark -

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    if(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nibBundleOrNil]) {
    }
    return self;
}

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
    
    //整体背景图
    _imageAllBG.clipsToBounds = YES;
    [_imageAllBG addTapGesture:self selector:@selector(dismissKeyboard)];
    [_imageAllBG setUIImageWithURL:UIGlobalImageBackground placeholderImage:nil completed:nil];
    
    //导航条
    UIColor *_color  = [UIColor whiteColor];
    _imageNavBG.backgroundColor = [UIColor clearColor];
    _labelTitle.textColor = _color;
    [_labelTitle setFont:[UIFont systemFontOfSize:17.0f] ];
    [_buttonNavLeft setImage:[UIImage imageNamed:@"normal.bundle/导航_返回.png"] forState:UIControlStateNormal];
    
    //用户名
    _iconUsername.image = [UIImage imageNamed:@"normal.bundle/登录_用户名.png"];
    _textFieldUsername.keyboardType = UIKeyboardTypePhonePad;
    _textFieldUsername.textColor = _color;
    _textFieldUsername.font = [UIFont systemFontOfSize:17.0];
    _textFieldUsername.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.username"];
    
    //密码
    _iconPassword.image = [UIImage imageNamed:@"normal.bundle/登录_密码.png"];
    _textFieldPassword.secureTextEntry = YES;
    _textFieldPassword.textColor = _color;
    _textFieldPassword.font = [UIFont systemFontOfSize:15.0];
    
    //分割线1
    _viewLine1.backgroundColor = [UIColor colorWithRGB:0xffffff alpha:0.3];
    
    //记住用户
    [_buttonKeep.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [_buttonKeep setTitleColor:_color forState:UIControlStateNormal];
    [_buttonKeep.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_buttonKeep setImage:[UIImage imageNamed:@"normal.bundle/圆形_未选中.png"] forState:UIControlStateNormal];
    [_buttonKeep setImage:[UIImage imageNamed:@"normal.bundle/圆形_选中.png"] forState:UIControlStateSelected];
    [_buttonKeep setSelected:YES]; //默认记住用户名
    
    //忘记密码
    [_buttonForget.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [_buttonForget setTitleColor:_color forState:UIControlStateNormal];
    
    //登录
    _buttonLogin.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_buttonLogin.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [_buttonLogin setTitleColor:_color forState:UIControlStateNormal];
    [_buttonLogin setCornerWithRadius:CGRectGetHeight(_buttonLogin.frame)/2.0];
    
    //第三方登录文本
    _label3Login.textColor = _color;
    _label3Login.font = [UIFont systemFontOfSize:15.0];
    
    //第三方登录文本分割线
    _viewLine2.backgroundColor = [UIColor colorWithRGB:0xffffff alpha:0.3];
    
    //微信
    [_buttonWeiXin setBackgroundColor:[UIColor whiteColor] ];
    [_buttonWeiXin setImage:[UIImage imageNamed:@"ShareSDKUI.bundle/Icon_simple/sns_icon_22.png"] forState:UIControlStateNormal];
    [_buttonWeiXin setCornerWithRadius:CGRectGetHeight(_buttonWeiXin.frame)/2.0];
    
    //QQ
    [_buttonQQ setBackgroundColor:[UIColor whiteColor] ];
    [_buttonQQ setImage:[UIImage imageNamed:@"ShareSDKUI.bundle/Icon_simple/sns_icon_24.png"] forState:UIControlStateNormal];
    [_buttonQQ setCornerWithRadius:CGRectGetHeight(_buttonQQ.frame)/2.0];

    //新浪微博
    [_buttonSina setBackgroundColor:[UIColor whiteColor] ];
    [_buttonSina setImage:[UIImage imageNamed:@"ShareSDKUI.bundle/Icon_simple/sns_icon_1.png"] forState:UIControlStateNormal];
    [_buttonSina setCornerWithRadius:CGRectGetHeight(_buttonSina.frame)/2.0];
    
    //还没有账号? 注册
    _buttonRegister.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_buttonRegister.titleLabel setFont:[UIFont systemFontOfSize:15.0] ];
    [_buttonRegister setTitleColor:_color forState:UIControlStateNormal];
    [_buttonRegister setCornerWithRadius:CGRectGetHeight(_buttonRegister.frame)/2.0];
    
    //默认键盘聚焦
    //[_textFieldUsername becomeFirstResponder];
}

- (IBAction)didButtonSelect:(id)sender {

    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 0: //导航条左侧
        {
            if(self.completion) {self.completion(NO);}
            [self dismiss];
            break;
        }
        case 1: //记住密码
        {
            [_buttonKeep setSelected:!_buttonKeep.selected];
            break;
        }
        case 3: //登录
        {
            [self doLogin];
            break;
        }
        case 2: //忘记密码
        case 4: //还没有账号 ? 注册
        {
            UIRegisterViewController *vc = [[UIRegisterViewController alloc] init];
            vc.event = (tag == 4 ? UIPersonalEventRegister : UIPersonalEventForgetPassword);
            vc.mobile = _textFieldUsername.text;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 5: //微信
        case 6: //QQ
        case 7: //新浪微博
        {
            SSDKPlatformType type = SSDKPlatformTypeWechat;
            if(tag == 6) type = SSDKPlatformTypeQQ;
            else if(tag == 7) type = SSDKPlatformTypeSinaWeibo;
            [self do3PartyLogin:type];
            break;
        }
        default:
            break;
    }
}

- (void)doLogin {

    //检查数据输入有效性
    if(![self isValid]) return;
    
    //回调处理
    AVUserResultBlock block = ^(AVUser *user, NSError *error) {
        if(!error) {
            
            //若记住用户，则保存用户名
            if(_buttonKeep.selected) {
                [NSUserDefaults setObjectForKey:_textFieldUsername.text key:@"user.username"];
            }
            
            //登录成功处理
            [self successLoginHander];
        }
        else {
            //登录失败
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    };
    
    //使用手机号码和密码登录
    [SVProgressHUD showWithStatus:@"登录中..."];
    [AVUser logInWithMobilePhoneNumberInBackground:_textFieldUsername.text
                                          password:_textFieldPassword.text
                                             block:block];
}

- (void)do3PartyLogin:(SSDKPlatformType)type {

    [ShareSDK getUserInfo:type
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               
               switch (state) {
                   case SSDKResponseStateSuccess:
                       [SVProgressHUD showWithStatus:@"登录中..."];
                       [self bindAVUser:user platform:type];
                       break;
                   case SSDKResponseStateFail:
                       [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                       break;
                   case SSDKResponseStateCancel:
                       [SVProgressHUD showInfoWithStatus:@"授权取消"];
                       break;
                   default:
                       break;
               }
           }];
    
}

- (void)bindAVUser:(SSDKUser *)user platform:(SSDKPlatformType)platform {

    NSString *_platform;
    NSMutableDictionary *authData = [NSMutableDictionary dictionaryWithDictionary:user.credential.rawData];
    switch (platform) {
        case SSDKPlatformTypeWechat:
            _platform = AVOSCloudSNSPlatformWeiXin;
            break;
        case SSDKPlatformTypeQQ:
            _platform = AVOSCloudSNSPlatformQQ;
            break;
        default:
            _platform = AVOSCloudSNSPlatformWeiBo;
            id expires_in = user.credential.rawData[@"expires_in"];
            if(expires_in) {[authData setObject:expires_in forKey:@"expiration_in"];}
            break;
    }
    
    [AVUser loginWithAuthData:authData
                     platform:_platform
                        block:^(AVUser *_user, NSError *error) {
                            
                            if(!error) {
                                
                                //增加判断对于第三方绑定是否需要同步头像、昵称、性别等信息
                                if([_user objectForKey:@"avatar"] && [_user objectForKey:@"nickname"]) {
                                    
                                    //登录成功处理
                                    [self successLoginHander];
                                }
                                else {
                                    if(user.nickname) {[_user setObject:user.nickname forKey:@"nickname"];}
                                    if(user.icon){
                                        //qq登录，头像单独处理
                                        if ([_platform isEqualToString:@"qq"]) {
                                            [_user setObject:[user.rawData objectForKey:@"figureurl_qq_2"] forKey:@"avatar"];
                                        }else{
                                            [_user setObject:user.icon forKey:@"avatar"];
                                        }
                                    }
                                    if(user.gender)   {[_user setObject:@(user.gender) forKey:@"sex"];}
                                    [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        
                                        //登录成功处理
                                        [self successLoginHander];
                                    }];
                                }
                            }
                            else {
                                //登录失败
                                [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                            }
    }];
}

- (void)successLoginHander {
    
    //消失模式对话框
    [SVProgressHUD dismiss];
    
    //通知事件
    postNotificationName(didPersonalInfoChangeNotification, nil, @{@"isLogin" : @(1)});
    if(self.completion) {self.completion(YES);}
    
    //登录成功
    [self dismiss];
}

- (BOOL)isValid {
    
    //手机号码检测是否为空、长度是否等于11、且首位数字必须是1
    NSString *mobile = _textFieldUsername.text;
    if(mobile == nil || mobile.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"手机号码不能为空"];
        return NO;
    }
    else if(mobile.length != 11 || ![[mobile substringToIndex:1] isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"手机号码输入有误"];
        return NO;
    }
    
    //密码检测是否为空、长度大于6位，且小于20位
    NSString *password = _textFieldPassword.text;
    if(password == nil || password.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"密码不能为空"];
        return NO;
    }
    else if(password.length < 6 || password.length > 20) {
        [SVProgressHUD showInfoWithStatus:@"密码输入有误"];
        return NO;
    }
    
    return YES;
}

- (void)dismiss {
    
    id vc = [self.navigationController popViewControllerAnimated:YES];
    if(!vc) [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)dismissKeyboard {
    
    [_textFieldUsername resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    //rang.length 等于0表示输入字符，大于0则是删除字符
    NSInteger max = (textField == _textFieldUsername ? 11 : 20);
    if(range.length == 0 && textField.text.length >= max) {
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}

@end
