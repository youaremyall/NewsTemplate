//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <JavaScriptCore/JavaScriptCore.h>
#import "SVWebViewController.h"
#import "SDWebImage+Extension.h"
#import "UIView+SDAutoLayout.h"
#import "UIView+Extension.h"
#import "IMTWebView.h"
#import "JSObjCModel.h"
#import "TRSTA+Provider.h"
#import "TRSMobile.h"


@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    
    return YES;
}

@end

@interface SVWebViewController () <UIWebViewDelegate>
{
    __strong UIButton           *_buttonClose;
    __strong IMTWebView         *_webView;
    __strong UIProgressView     *_progressView;
    
    NSURLRequest                *_request;
}
@property (nonatomic, strong) JSContext   *context;

@end


@implementation SVWebViewController

#pragma mark - Initialization

- (instancetype)initWithURL:(NSString *)URL {
    
    if(self = [super init]) {
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    }
    return self;
}

- (void)dealloc {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUIControls];
    [self loadRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark -
- (void) initUIControls {
    
    [self setUINavbar];
    [self initUIWebView];
    [self handleEventBlocks];
}

- (void)setUINavbar {
    
    /*关闭图标*/
    _buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonClose.frame = CGRectMake(44.0 + 8.0, 20.0, 44.0, 44.0);
    _buttonClose.hidden = YES;
    [_buttonClose setImage:[UIImage imageNamed:@"normal.bundle/导航_关闭.png"] forState:UIControlStateNormal];
    [_buttonClose setImageEdgeInsets:UIEdgeInsetsMake(0, 8.0, 0, 0)];
    [_buttonClose addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.navbar addSubview:_buttonClose];
}

- (void) initUIWebView {
    
    _webView = [[IMTWebView alloc] init];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.trackTintColor = [UIColor lightGrayColor];
    _progressView.progressTintColor = [UIColor orangeColor];
    [_webView addSubview:_progressView];
    
    _webView.sd_layout
    .topSpaceToView(_isInset ? self.view : self.navbar, 0)
    .bottomSpaceToView(self.view, 0)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0);
    
    _progressView.sd_layout
    .topSpaceToView(_webView, 0)
    .leftSpaceToView(_webView, 0)
    .rightSpaceToView(_webView, 0)
    .heightIs(2.0);
}

- (void)updateWebTitle {
    
    //标题
    [self.navbar.barTitle setText:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"] ];
    
    //关闭按钮的显示与隐藏
    [_buttonClose setHidden:!_webView.canGoBack];
    
    //调整文字
    self.navbar.barTitle.x = _buttonClose.hidden ? CGRectGetMaxX(self.navbar.barLeft.frame) : CGRectGetMaxX(_buttonClose.frame);
}

- (void) handleEventBlocks {
    
    __weak __typeof(self) wself = self;
    __weak __typeof(UIWebView *) wwebview = _webView;
    __weak __typeof(UIProgressView *) wprogress = _progressView;
    
    self.navbar.clickEvent = ^(NSDictionary *dict, NSInteger index) {
        
        switch (index) {
            default:
            {
                if(wwebview.canGoBack) {[wwebview goBack]; return;}
                [wself dismiss];
                break;
            }
        }
    };
    
    _webView.progressValueChanged = ^(CGFloat progress) {
        
        wprogress.hidden = (progress == 1.0);
        [wprogress setProgress:(progress == 1.0 ? 0 : progress) animated:YES];
    };
}

- (void)dismiss {
    
    id vc = [self.navigationController popViewControllerAnimated:YES];
    if(!vc) [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)loadRequest {
    
    [_webView loadRequest:_request];
}

#pragma mark - JSExport
- (void)configJSContext:(NSURLRequest *)request {
    
    //构建虚拟透明网页控件
    UIWebView *__webVitual = [[UIWebView alloc] initWithFrame:_webView.frame];
    [__webVitual setHidden:YES];
    [self.view addSubview:__webVitual];
    [__webVitual loadRequest:request];
    
    //获取JS运行环境
    self.context = [__webVitual valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //打印异常
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息 ： %@", exceptionValue);
    };
    
    //以 JSExport 协议关联 native 的方法 (此方法需要实现JSExport协议)
    JSObjCModel *model = [JSObjCModel new];
    model.controller = self;
    self.context[@"mobile"] = model;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [self configJSContext:request]; //配置JSContext
    
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateWebTitle];
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateWebTitle];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateWebTitle];
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

@end
