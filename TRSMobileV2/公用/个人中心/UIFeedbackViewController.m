//
//  UIFeedbackViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/10.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIFeedbackViewController.h"
#import "Globals.h"

@interface UIFeedbackViewController () <UITextViewDelegate>
{
    __strong UITextView    *_textView;
    __strong UILabel       *_labelTip;
    __strong UIButton      *_button;
}
@end

@implementation UIFeedbackViewController

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
    
    [self.navbar.barTitle setText:@"意见反馈"];
    [self initUIContent];
}

- (void)initUIContent {

    //文本编辑背景
    UIView *_view1 = [[UIView alloc] init];
    _view1.backgroundColor = [UIColor whiteColor];
    [_view1 setCornerWithRadius:4.0];
    [self.view addSubview:_view1];
    
    _view1.sd_layout
    .topSpaceToView(self.navbar, 20)
    .leftSpaceToView(self.view, 20)
    .rightSpaceToView(self.view, 20)
    .heightIs(180.0);
    
    //文本输入框
    _textView = [[UITextView alloc] init];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor blackColor];
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textView.font = [UIFont systemFontOfSize:15.0];
    _textView.delegate = self;
    [_textView becomeFirstResponder];
    [_view1 addSubview:_textView];
    
    _textView.sd_layout
    .topSpaceToView(_view1, 4.0)
    .bottomSpaceToView(_view1, 4.0)
    .leftSpaceToView(_view1, 4.0)
    .rightSpaceToView(_view1, 4.0);
    
    //文本占位提示
    _labelTip = [[UILabel alloc] init];
    _labelTip.backgroundColor = [UIColor clearColor];
    _labelTip.textColor = [UIColor lightGrayColor];
    _labelTip.font = [UIFont systemFontOfSize:13.0];
    _labelTip.text = @"写点什么吧...";
    [_view1 addSubview:_labelTip];
    
    _labelTip.sd_layout
    .topSpaceToView(_view1, 12.0)
    .leftSpaceToView(_view1, 12.0)
    .rightSpaceToView(_view1, 12.0)
    .heightIs(21.0);
    
    //提交按钮
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.backgroundColor = [UIColor colorRandomWithAlpha:0.8];
    [_button setTitle:@"提交" forState:UIControlStateNormal];
    [_button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:UIColorThemeDefault] cornerRadius:0] forState:UIControlStateNormal];
    [_button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:0x6e6e6e] cornerRadius:0] forState:UIControlStateDisabled];
    [_button addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_button setEnabled:NO];
    [_button setCornerWithRadius:4.0];
    [self.view addSubview:_button];
    
    _button.sd_layout
    .topSpaceToView(_view1, 20.0)
    .leftSpaceToView(self.view, 20.0)
    .rightSpaceToView(self.view, 20.0)
    .heightIs(44.0);
    
    [self.view addTapGesture:self selector:@selector(dismissKeyboard)];
}

- (void)didButtonSelect:(id)sender {

    [SVProgressHUD showWithStatus:@"提交中..."];
    NSDictionary *__dict = @{@"content" : _textView.text};
    AVObject *__object = [AVObject objectWithClassName:@"Feedback" dictionary:__dict];
    [__object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"已提交"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    }];
}

- (void)setTipStatus {
    
    BOOL isValid = _textView.text && _textView.text.length && ![_textView.text isEqualToString:@""];
    _labelTip.hidden = isValid;
    _button.enabled = isValid;
}

- (void)dismissKeyboard {
    
    [_textView resignFirstResponder];
}

#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

    [self setTipStatus];
}

@end
