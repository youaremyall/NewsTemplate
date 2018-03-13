//
//  UIRegister2ViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/9.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIRegister2ViewController.h"
#import "Globals.h"

NSString *const didPersonalInfoChangeNotification = @"personalInfoDidChange";

@interface UIRegister2ViewController () <UITextFieldDelegate>
{

    /*整体背景图*/
    __weak IBOutlet UIImageView *_imageAllBG;
    
    /*导航条背景*/
    __weak IBOutlet UIImageView *_imageNavBG;
    
    /*导航条左侧按钮*/
    __weak IBOutlet UIButton *_buttonNavLeft;
    
    /*导航条标题*/
    __weak IBOutlet UILabel *_labelTitle;
    
    /*校验码*/
    __weak IBOutlet UIView *_viewVerifyCode;
    __weak IBOutlet UITextField *_textFieldVerifyCode;
    __weak IBOutlet UIButton *_buttonVerifyCode;
    
    /*密码*/
    __weak IBOutlet UIView *_viewPassword;
    __weak IBOutlet UITextField *_textFieldPassword;
    
    /*提交*/
    __weak IBOutlet UIButton *_buttonSubmit;
    
    /*校验码计时器*/
    NSInteger                _timerSecond;
    NSTimer                  *_timerVerifyCode;
}
@end

@implementation UIRegister2ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUIContorls];
    [self getVerifySMSCode];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    if(_timerVerifyCode) { /*计时器在页面结束的时候必须释放，否则会导致由于计时器启动而到时引用计数+1，返回后所占的内存不会被释放。*/
        [_timerVerifyCode invalidate];
        _timerVerifyCode = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIContorls {

    //整体背景图
    _imageAllBG.clipsToBounds = YES;
    [_imageAllBG addTapGesture:self selector:@selector(dismissKeyboard)];
    [_imageAllBG setUIImageWithURL:UIGlobalImageBackground placeholderImage:nil completed:nil];
    
    //导航条
    _imageNavBG.backgroundColor = [UIColor clearColor];
    [_buttonNavLeft setImage:[UIImage imageNamed:@"normal.bundle/导航_返回.png"] forState:UIControlStateNormal];
    [_labelTitle setFont:[UIFont systemFontOfSize:17.0f] ];
    [_labelTitle setText:@[@"注册", @"找回密码", @"绑定手机"][_event] ];

    //校验码
    _textFieldVerifyCode.font = [UIFont systemFontOfSize:15.0];
    [_textFieldVerifyCode setTextColor:[UIColor whiteColor] ];
    
    _viewVerifyCode.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_buttonVerifyCode setCornerWithRadius:CGRectGetHeight(_buttonVerifyCode.frame)/2.0];
    [_viewVerifyCode setCornerWithRadius:CGRectGetHeight(_viewVerifyCode.frame)/2.0];
    
    //密码
    _textFieldPassword.secureTextEntry = YES;
    _textFieldPassword.font = [UIFont systemFontOfSize:15.0];
    [_textFieldPassword setTextColor:[UIColor whiteColor] ];
    
    _viewPassword.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_viewPassword setCornerWithRadius:CGRectGetHeight(_viewPassword.frame)/2.0];
    
    //提交
    _buttonSubmit.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _buttonSubmit.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_buttonSubmit setCornerWithRadius:CGRectGetHeight(_buttonSubmit.frame)/2.0];
}

- (IBAction)didButtonSelect:(id)sender {

    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 0: //导航条左侧按钮
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case 1: //获取验证码
            [self getVerifySMSCode];
            break;
            
        case 2: //提交
            [self doSubmit];
            break;
            
        default:
            break;
    }
}

- (void)setVerifycodeTimer {
    
    _timerSecond = 60;
    if(!_timerVerifyCode) {
        _timerVerifyCode = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(updateVerify)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    [_timerVerifyCode resumeTimer];
}

- (void)updateVerify {

    --_timerSecond;
    if(_timerSecond == 0) {
        [_timerVerifyCode pauseTimer];
        _buttonVerifyCode.backgroundColor = [UIColor blackColor];
        [_buttonVerifyCode setEnabled:YES];
        [_buttonVerifyCode setTitle:@"获取校验码" forState:UIControlStateNormal];
    }
    else {
        _buttonVerifyCode.backgroundColor = [UIColor lightGrayColor];
        [_buttonVerifyCode setEnabled:NO];
        [_buttonVerifyCode setTitle:[NSString stringWithFormat:@"重新发送%ld", _timerSecond] forState:UIControlStateNormal];
    }
}

- (void)doSubmit {

    //检查数据输入有效性
    if(![self isValid]) return;
    
    NSString *tip;
    if(UIPersonalEventRegister == _event)
        tip = @"正在注册...";
    else if(UIPersonalEventForgetPassword == _event)
        tip = @"正在重置...";
    else if(UIPersonalEventBindMobile == _event)
        tip = @"正在绑定...";

    [SVProgressHUD showWithStatus:tip];
    
    switch (_event) {
        case UIPersonalEventForgetPassword : //找回密码
        {
            [self doNext];
            break;
        }
        case UIPersonalEventRegister: //普通注册
        case UIPersonalEventBindMobile : //绑定手机
        {
            [AVOSCloud verifySmsCode:_textFieldVerifyCode.text
                   mobilePhoneNumber:_mobile
                            callback:^(BOOL succeeded, NSError *error) {
                                
                                if(succeeded) {
                                    [self doNext];
                                }
                                else {
                                    [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                                }
                            }];
            break;
        }
        default:
            break;
    }
}

- (void)doNext {

    switch (_event) {
        case UIPersonalEventRegister: //普通注册
        {
            AVUser *user = [AVUser user]; // 新建 AVUser 对象实例
            user.username = _mobile;
            user.mobilePhoneNumber = _mobile;
            user.password = _textFieldPassword.text;
            [user setObject:[NSString stringWithFormat:@"手机用户%@", _mobile] forKey:@"nickname"];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                    [self dismiss];
                }
                else {
                    [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                }
            }];
            break;
        }
        case UIPersonalEventForgetPassword: //找回密码
        {
            [AVUser resetPasswordWithSmsCode:_textFieldVerifyCode.text
                                 newPassword:_textFieldPassword.text
                                       block:^(BOOL succeeded, NSError *error) {
                                           if(succeeded) {
                                               [SVProgressHUD showSuccessWithStatus:@"重置成功"];
                                               [self dismiss];
                                           }
                                           else {
                                               [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                                           }
                                       }];
            break;
        }
        case UIPersonalEventBindMobile: //绑定手机
        {
            AVUser *user = [AVUser currentUser];
            user.mobilePhoneNumber = _mobile;
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
                    [self dismiss];
                }
                else {
                    [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
                }
                
            }];
            break;
        }
        default:
            break;
    }
}

- (void)getVerifySMSCode {
    
    //设置计时器
    [self setVerifycodeTimer];
    
    //调用第三方组件LeanCloud获取短信验证码
    switch (_event) {
        case UIPersonalEventForgetPassword: //找回密码
        {
            [AVUser requestPasswordResetWithPhoneNumber:_mobile
                                                  block:^(BOOL succeeded, NSError *error) {
                                                      if(!succeeded) {
                                                          [SVProgressHUD showInfoWithStatus:[AVOSCloud errorString:error.code] ];
                                                      }
                                                  }];
            break;
        }
        case UIPersonalEventRegister:   //普通注册
        case UIPersonalEventBindMobile: //绑定手机
        {
            [AVSMS requestShortMessageForPhoneNumber:_mobile options:nil callback:^(BOOL succeeded, NSError * _Nullable error) {
                if(!succeeded) {
                    [SVProgressHUD showInfoWithStatus:[AVOSCloud errorString:error.code] ];
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (BOOL)isValid {
    
    //手机号码检测是否为空、长度是否等于11、且首位数字必须是1
    NSString *verifycode = _textFieldVerifyCode.text;
    if(verifycode == nil || verifycode.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"验证码不能为空"];
        return NO;
    }
    else if(verifycode.length < 4 || verifycode.length > 6) {
        [SVProgressHUD showInfoWithStatus:@"验证码输入有误"];
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
    
    [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3] animated:YES];
}

- (void)dismissKeyboard {

    [_textFieldVerifyCode resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //rang.length 等于0表示输入字符，大于0则是删除字符
    NSInteger max = (textField == _textFieldVerifyCode ? 6 : 20);
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
