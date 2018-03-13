//
//  UIRegisterViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIRegisterViewController.h"
#import "Globals.h"

@interface UIRegisterViewController () <UITextFieldDelegate>
{
    /*整体背景图*/
    __weak IBOutlet UIImageView *_imageAllBG;

    /*导航条背景图*/
    __weak IBOutlet UIImageView *_imageNavBG;
    
    /*导航条左侧按钮*/
    __weak IBOutlet UIButton *_buttonNavLeft;
    
    /*导航条标题*/
    __weak IBOutlet UILabel *_labelTitle;
    
    /*手机号码输入框*/
    __weak IBOutlet UIView *_viewTextFieldUsername;
    __weak IBOutlet UITextField *_textFieldUsername;
    
    /*下一步*/
    __weak IBOutlet UIButton *_buttonNext;
    
    /*同意按钮*/
    __weak IBOutlet UIButton *_buttonAgree;
    
    /*同意(用户协议)文本*/
    __weak IBOutlet UIButton *_labelAgree;
}

@end

@implementation UIRegisterViewController

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
- (void)initUIControls {

    //整体背景图
    _imageAllBG.clipsToBounds = YES;
    [_imageAllBG addTapGesture:self selector:@selector(dismissKeyboard)];
    [_imageAllBG setUIImageWithURL:UIGlobalImageBackground placeholderImage:nil completed:nil];
    
    //导航条
    _imageNavBG.backgroundColor = [UIColor clearColor];
    [_buttonNavLeft setImage:[UIImage imageNamed:@"normal.bundle/导航_返回.png"] forState:UIControlStateNormal];
    [_labelTitle setFont:[UIFont systemFontOfSize:17.0f] ];
    [_labelTitle setText:@[@"注册", @"找回密码", @"绑定手机"][_event] ];
    
    //用户名
    _textFieldUsername.keyboardType = UIKeyboardTypePhonePad;
    _textFieldUsername.font = [UIFont systemFontOfSize:15.0];
    _textFieldUsername.text = _mobile;
    [_textFieldUsername setTextColor:[UIColor whiteColor] ];
    
    _viewTextFieldUsername.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_viewTextFieldUsername setCornerWithRadius:CGRectGetHeight(_viewTextFieldUsername.frame)/2.0];
    
    //下一步
    _buttonNext.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _buttonNext.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_buttonNext setCornerWithRadius:CGRectGetHeight(_buttonNext.frame)/2.0];
    
    //同意(用户协议)
    [_buttonAgree.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [_buttonAgree.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_buttonAgree setImage:[UIImage imageNamed:@"normal.bundle/圆形_未选中.png"] forState:UIControlStateNormal];
    [_buttonAgree setImage:[UIImage imageNamed:@"normal.bundle/圆形_选中.png"] forState:UIControlStateSelected];
    [_buttonAgree setSelected:YES]; //默认同意用户协议
    [_buttonAgree setHidden:(UIPersonalEventRegister !=_event)];
    
    //同意(用户协议)文本
    [_labelAgree.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [_labelAgree setHidden:(UIPersonalEventRegister !=_event)];
}

- (IBAction)didButtonSelect:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 0: //返回
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1: //下一步
        {
            [self doNext];
            break;
        }
        case 2: //勾选用户协议
        {
            [_buttonAgree setSelected:!_buttonAgree.selected];
            break;
        }
        case 3: //用户协议
        {
            SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:valueForDictionaryFile(@"website")[@"UserAgreementUrl"] ];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        default:
            break;
    }
}

- (void)doNext {

    //检查数据输入有效性
    if(![self isValid]) return;
    
    //1.-->先判断用户是否存在
    [SVProgressHUD showWithStatus:@"加载中..."];
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"mobilePhoneNumber" equalTo:_textFieldUsername.text];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        
        if(!error) {
            
            if((UIPersonalEventRegister == _event && number == 0)   //普通注册且用户不存在
               || (UIPersonalEventForgetPassword == _event && number != 0) )    //找回密码且用户已存在
            {
                [SVProgressHUD dismiss];
                
                UIRegister2ViewController *vc = [[UIRegister2ViewController alloc] init];
                vc.event = _event;
                vc.mobile = _textFieldUsername.text;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                if(UIPersonalEventRegister == _event)
                    [SVProgressHUD showInfoWithStatus:@"此手机号已被注册"];
                else if(UIPersonalEventForgetPassword == _event)
                    [SVProgressHUD showInfoWithStatus:@"此手机号尚未注册"];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    }];
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
    
    return YES;
}

- (void)dismissKeyboard {
    
    [_textFieldUsername resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //rang.length 等于0表示输入字符，大于0则是删除字符
    if(range.length == 0 && textField.text.length >= 11) {
        
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}

@end
