//
//  UIPersonalEditViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/6/16.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "UIPersonalEditViewController.h"
#import "Globals.h"

@interface UIPersonalEditViewController () <UITextFieldDelegate>
{
    __strong UITextField   *_textField;
}
@end

@implementation UIPersonalEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUIControls];
    addNotificationObserver(self, @selector(textDidChange), UITextFieldTextDidChangeNotification, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initUIControls {
    
    [self setUINavbar];
    [self initUIInputDialog];
    [self.view addTapGesture:self selector:@selector(dismissKeyboard)];
}

- (void)setUINavbar {
    
    __weak __typeof(self) wself = self;
    self.navbar.clickEvent = ^(NSDictionary *dict , NSInteger index) {
        switch (index) {
            case 0:
                [wself.navigationController popViewControllerAnimated:YES];
                break;
            case 1:
                [wself doSave];
                break;
            default:
                break;
        }
    };
    [self.navbar.barTitle setText:self.dict[@"title"] ];
    [self.navbar.barRight setTitle:@"保存" forState:UIControlStateNormal];
    [self.navbar.barRight setEnabled:NO];
}

- (void)initUIInputDialog {

    UIView *_view = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.navbar.frame) + 20.0, CGRectGetWidth(self.view.frame) - 40.0, 40.0)];
    _view.backgroundColor = [UIColor whiteColor];
    [_view setCornerWithRadius:CGRectGetHeight(_view.frame)/2.0];
    [self.view addSubview:_view];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_view.frame) - 20.0, CGRectGetHeight(_view.frame))];
    _textField.delegate = self;
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.spellCheckingType = UITextSpellCheckingTypeNo;
    _textField.font = [UIFont systemFontOfSize:15.0];
    _textField.textColor = [UIColor blackColor];
    _textField.text = self.dict[@"text"];
    _textField.placeholder = [self.dict[@"type"] integerValue] == 0 ? @"请输入昵称" : @"请输入个性签名";
    [_view addSubview:_textField];
}

#pragma mark -
- (void)doSave {

    if(![self isValid]) return;
    
    [SVProgressHUD showWithStatus:@"保存中..."];
    NSInteger type = [self.dict[@"type"] integerValue];
    AVUser *user = [AVUser currentUser];
    switch (type) {
        case 0: //昵称
            [user setObject:_textField.text forKey:@"nickname"];
            break;
        case 2: //签名
            [user setObject:_textField.text forKey:@"signature"];
            break;
        default:
            break;
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            if(self.clickEvent) {self.clickEvent(nil, 1);}
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    }];
}

- (BOOL)isValid {

    NSString *text = _textField.text;
    if(text == nil || text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"内容不能为空"];
        return NO;
    }
    return YES;
}

- (void)dismissKeyboard {
    
    [_textField resignFirstResponder];
}

#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //rang.length 等于0表示输入字符，大于0则是删除字符
    if(range.length == 0 && textField.text.length >= 30) {
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textDidChange {
    
    [self.navbar.barRight setEnabled:!([self.dict[@"text"] isEqualToString:_textField.text]) ];
}

@end
