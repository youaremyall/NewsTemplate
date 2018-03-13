//
//  UICommentPostView.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/5/26.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UICommentPostView.h"
#import "UILoginViewController.h"
#import "Globals.h"

NSString *const didCommentPostNotification = @"commentDidPost";

@interface UICommentPostView () <UITextViewDelegate>
{
    /*发表评论整体视图*/
    UIView      *_viewComment;
    
    /*发送按钮*/
    UIButton    *_btnSend;
    
    /*发表评论文本输入框*/
    UITextView  *_textView;
    
    /*占位提示文字*/
    UILabel     *_labelTip;
    
    /*剩余可输入字符个数提示*/
    UILabel     *_lableLimit;
}

@end

@implementation UICommentPostView

- (instancetype) initWithFrame:(CGRect)frame {

    if(self = [super initWithFrame:frame]) {
        
        self.maxLimit = NSIntegerMax;
        [self setup];
        [self setTipStatus];
        addNotificationObserver(self, @selector(keyboardWillChangeFrame:), UIKeyboardWillChangeFrameNotification, nil);
    }
    return self;
}

- (void)dealloc {
    
    removeNotifcationObserverAll(self);
}

#pragma mark -
- (void)setup {

    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.0f;
    
    //背景图层
    UIView *viewBG = [[UIView alloc] initWithFrame:self.bounds];
    viewBG.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [viewBG addTapGesture:self selector:@selector(dismiss)];
    [self addSubview:viewBG];
    
    //写评论图层
    _viewComment = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 160.0)];
    _viewComment.backgroundColor = [UIColor colorWithRGB:0xeeeeee alpha:1.0];
    [self addSubview:_viewComment];
    
    //关闭
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(0, 0, 44, 44);
    btnClose.tag = 0;
    btnClose.backgroundColor = [UIColor clearColor];
    btnClose.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnClose setTitle:@"取消" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewComment addSubview:btnClose];
    
    //发表
    _btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSend.frame = CGRectMake(CGRectGetWidth(self.frame) - 44, 0, 44, 44);
    _btnSend.tag = 1;
    _btnSend.backgroundColor = [UIColor clearColor];
    _btnSend.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_btnSend setTitle:@"提交" forState:UIControlStateNormal];
    [_btnSend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnSend setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_btnSend addTarget:self action:@selector(didButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_viewComment addSubview:_btnSend];
    
    //写评论...
    UILabel *labelTitle = [[UILabel alloc] init];
    labelTitle.frame = CGRectMake(44.0, 0.0, CGRectGetWidth(self.frame) - 2 * 44.0, 44.0);
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = @"写评论";
    labelTitle.font = [UIFont systemFontOfSize:17.0];
    [_viewComment addSubview:labelTitle];
    
    //文本编辑背景
    UIView *viewContent = [[UIView alloc] init];
    viewContent.frame = CGRectMake(8.0, 44.0 + 4.0, CGRectGetWidth(self.frame) - 2*8.0, 100.0);
    viewContent.backgroundColor = [UIColor whiteColor];
    [viewContent setCornerWithRadius:2.0];
    [_viewComment addSubview:viewContent];
    
    //文本输入框
    _textView = [[UITextView alloc] init];
    _textView.frame = CGRectMake(4.0, 0, CGRectGetWidth(viewContent.frame) - 8.0, CGRectGetHeight(viewContent.frame));
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor blackColor];
    _textView.font = [UIFont systemFontOfSize:13.0];
    _textView.delegate = self;
    [viewContent addSubview:_textView];

    //文本占位提示
    _labelTip = [[UILabel alloc] init];
    _labelTip.frame = CGRectMake(8.0, 4.0, CGRectGetWidth(viewContent.frame) - 16.0, 21.0);
    _labelTip.backgroundColor = [UIColor clearColor];
    _labelTip.textColor = [UIColor lightGrayColor];
    _labelTip.font = [UIFont systemFontOfSize:13.0];
    _labelTip.text = @"写点什么吧...";
    [viewContent addSubview:_labelTip];
    
    /*剩余可输入字符个数提示*/
    _lableLimit = [[UILabel alloc] init];
    _lableLimit.frame = CGRectMake(CGRectGetWidth(viewContent.frame) - 32.0 - 4.0, CGRectGetHeight(viewContent.frame) - 16.0 - 4.0, 32.0, 16.0);
    _lableLimit.backgroundColor = [UIColor colorWithRGB:0xff0000 alpha:0.6];
    _lableLimit.textColor = [UIColor whiteColor];
    _lableLimit.textAlignment = NSTextAlignmentCenter;
    _lableLimit.font = [UIFont systemFontOfSize:11.0];
    _lableLimit.hidden = YES;
    [_lableLimit setCornerWithRadius:8.0];
    [viewContent addSubview:_lableLimit];
    
    [_textView becomeFirstResponder];
}

- (void)setMaxLimit:(NSInteger)maxLimit {

    _maxLimit = maxLimit;
    _lableLimit.hidden = (maxLimit <= 0);
    _lableLimit.text = [NSString stringWithFormat:@"%ld", maxLimit];
}

- (void)setTipStatus {

    _labelTip.hidden = (_textView.text.length > 0);
    _btnSend.enabled = (_textView.text.length > 0);
}

- (void)didButtonSelect:(id)sender {

    NSInteger tag = ((UIButton *)sender).tag;
    if(tag != 0) {
        
        /*先判断用户是否已经登录*/
        if(![AVUser currentUser]) {
            
            [_textView resignFirstResponder];
            [UILoginViewController showLoginInVC:GDelegate.navTab completion:^(BOOL success){
                
                if(success) {
                    [self doSubmit];
                }
                else {
                    [_textView becomeFirstResponder];
                }
            }];
        }
        else {
            [self doSubmit];
        }
    }
    else {
        [self dismiss];
    }
}

- (void)doSubmit {

    [SVProgressHUD showWithStatus:@"提交中..."];
    NSDictionary *__dict = @{@"docId" : [_dict objectForVitualKey:@"docId"],
                             @"docType" : @(_type),
                             @"docValue" : _dict,
                             @"status" : (_commentPolicy == commentPolicyReviewFirst ? @(commentStatusReview) : @(commentStatusYesPre)),
                             @"isUserHide" : [NSUserDefaults settingValueForType:SettingTypeCommentNoUser],
                             @"user"  : [AVUser currentUser],
                             @"content" : _textView.text};
    
    AVObject *__comment = [AVObject objectWithClassName:@"Comment" dictionary:__dict];
    [__comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(succeeded) {
            [SVProgressHUD showSuccessWithStatus:(_commentPolicy == commentPolicyReviewFirst ? @"提交成功，等待审核中" : @"评论成功") ];
            if(_commentPolicy == commentPolicySendFirst) {
                postNotificationName(didCommentPostNotification, nil, nil);
            }
            [_textView setText:nil]; //清空已经发表的内容.
            [self dismiss];
        }
        else {
            [SVProgressHUD showErrorWithStatus:[AVOSCloud errorString:error.code] ];
        }
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [_textView resignFirstResponder];
                     }
                     completion:^(BOOL finished) {
                         if(_dismissBlock) {_dismissBlock();}
                         [self removeFromSuperview];
                     }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
    if(_maxLimit > 0) {
        [_lableLimit setText:[NSString stringWithFormat:@"%ld", (_maxLimit - textView.text.length) ] ];
    }
    
    [self setTipStatus];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //rang.length 等于0表示输入字符，大于0则是删除字符
    if(range.length == 0 && textView.text.length >= _maxLimit) {
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Notification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {

    NSDictionary *userInfo = notification.userInfo;
    CGRect frame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (frame.origin.y == CGRectGetHeight(self.frame)) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0f;
                             _viewComment.sd_layout
                             .yIs(CGRectGetHeight(self.frame));
        }];
    }
    else{
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 1.0f;
                             _viewComment.sd_layout
                             .yIs(CGRectGetHeight(self.frame) - CGRectGetHeight(_viewComment.frame) - frame.size.height);
        }];
    }
}

@end
