//
//  UIHtmlDetailViewController.m
//  TRSMobileV2
//
//  Created by  TRS on 16/5/3.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "UIHtmlDetailViewController.h"
#import "UIHtmlLoadingView.h"
#import "IMTWebView.h"
#import "JSObjCModel.h"
#import "Globals.h"

@interface UIHtmlDetailViewController () <UIWebViewDelegate, UIScrollViewDelegate>
{
    __strong  UIButton          *_buttonClose;
    __strong  UIToolbarView     *_toolbar;
    __strong  IMTWebView        *_webView;
    __strong  UIProgressView    *_progressView;
    __strong  UIHtmlLoadingView *_loadingView;
    
    CGFloat                     contentOffsetY;
    NSDictionary                *_webResult;
}
@property (nonatomic, strong) JSContext   *context;

@end

@implementation UIHtmlDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _hasToolbar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUIControls];
    [self loadWebContent];
    
#if isMyReadingEnable
    /*添加到我的阅读记录*/
    [StroageService setValue:@{@"type" : @(clickTypeDefault), @"content" : self.dict}
                      forKey:[self.dict objectForVitualKey:@"url"] serviceType:serviceTypeHistory];
#endif
    
    //上传文章属性统计数据
    if([self.dict objectForVitualKey:@"docId"]) {
        [self syncDocAnalytics:[self.dict objectForVitualKey:@"docId"] action:actionTypeRead completion:^(BOOL succeeded, NSError * _Nullable error) {
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
- (void) initUIControls {

    [self setUINavbar];
    [self initUIWebView];
    [self initUIToolbar];
    [self initUILoadingView];
    [self handleEventBlocks];
}

- (void)setUINavbar {
    
    [self.navbar.barRight setImage:[UIImage imageNamed:@"normal.bundle/导航_更多.png"] forState:UIControlStateNormal];

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
    _webView.scrollView.delegate = self;
    [self.view addSubview:_webView];
    _webView.sd_layout
    .topSpaceToView(self.navbar, 0)
    .bottomSpaceToView(self.view, (_hasToolbar ? kHeightUIToolbar : 0))
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0);

    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.trackTintColor = [UIColor lightGrayColor];
    _progressView.progressTintColor = [UIColor orangeColor];
    [_webView addSubview:_progressView];
    _progressView.sd_layout
    .topSpaceToView(_webView, 0)
    .leftSpaceToView(_webView, 0)
    .rightSpaceToView(_webView, 0)
    .heightIs(2.0);
}

- (void) initUIToolbar {
    
    if(!_hasToolbar) return;
    
    CGRect frame = CGRectMake(0, self.view.height -  kHeightUIToolbar, self.view.width, kHeightUIToolbar);
    _toolbar = [[UIToolbarView alloc] initWithFrame:frame];
    _toolbar.type = clickTypeDefault;
    _toolbar.commentPolicy = (self.dict[@"commentPolicy"] ? [self.dict[@"commentPolicy"] integerValue] : commentPolicySendFirst);
    _toolbar.vc = self;
    [_toolbar loadProperty];
    [self.view addSubview:_toolbar];
}

- (void) initUILoadingView {

    _loadingView = [[UIHtmlLoadingView alloc] initWithFrame:CGRectMake(0, self.navbar.height, screenWidth(), screenHeight() - self.navbar.height)];
    [self.view addSubview:_loadingView];
    [_loadingView startAmination];
}

- (UIScrollView *)scrollView {

    return _webView.scrollView;
}

- (void)updateWebTitle {

    //标题
    //[_navbar.barTitle setText:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"] ];
    
    //关闭按钮的显示与隐藏
    [_buttonClose setHidden:!_webView.canGoBack];
    
    //调整文字
    self.navbar.barTitle.x = _buttonClose.hidden ? CGRectGetMaxX(self.navbar.barLeft.frame) : CGRectGetMaxX(_buttonClose.frame);
}

- (void) handleEventBlocks {

    __weak __typeof(self) wself = self;
    __weak __typeof(IMTWebView *) wwebview = _webView;
    __weak __typeof(UIProgressView *) wprogress = _progressView;
   
    self.navbar.clickEvent = ^(NSDictionary *dict, NSInteger index) {
        
        switch (index) {
            case  1:
            {
                LCActionSheet *sheet = [LCActionSheet sheetWithTitle:@""
                                                   cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                                                       if(buttonIndex == 1) {
                                                           [GDelegate.navTab setCanDargBack:NO];
                                                           [GDelegate.vcDrawer setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionHorizontal];
                                                           [UISettingFontSizeView showInView:wself.view
                                                                                 changeBlock:^(NSInteger fontSize) {
                                                                                     [wwebview setWebViewHtmlFont];
                                                                                 }
                                                                                dismissBlock:^{
                                                                                    [GDelegate.navTab setCanDargBack:YES];
                                                                                    [GDelegate.vcDrawer setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionHorizontal];
                                                                                }
                                                            ];
                                                       }
                                                   } otherButtonTitleArray:@[@"字体调整", @"我要报错"]];
                sheet.buttonColor = [UIColor redColor];
                [sheet show];
                break;
            }
            default:
                if(wwebview.canGoBack) {[wwebview goBack]; return;}
                [wself dismiss];
                break;
        }
    };

    _webView.progressValueChanged = ^(CGFloat progress) {
        
        wprogress.hidden = (progress == 1.0);
        [wprogress setProgress:(progress == 1.0 ? 0 : progress) animated:YES];
    };
    
    _webView.clickEvevnt = ^(NSDictionary *dict) {
        
    };
}

- (void)dismiss {
    
    id vc = [self.navigationController popViewControllerAnimated:YES];
    if(!vc) [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark -
- (void)loadWebContent {
    
    NSString *url = [self.dict objectForVitualKey:@"url"];
    if([url rangeOfString:@".json"].location != NSNotFound) {
        [self webRequest:url];
    }
    else {
        NSURL *_url = [NSURL URLWithString:url];
        if(!_url.isFileURL) {
            [_webView loadRequest:[NSURLRequest requestWithURL:_url ] ];
        }
        else {
            NSString *prefix = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""].stringByDeletingPathExtension;
            NSString *path = [[NSBundle mainBundle] pathForResource:prefix ofType:url.pathExtension inDirectory:nil];
            NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            [_webView loadHTMLString:html baseURL:nil];
        }
    }
}

- (void)webRequest:(NSString *)url {

    /*缓存数据显示*/
    [self updateThisUI:url JSON:[StroageService valueForKey:url serviceType:serviceTypeDefault] ];
    
    /*加载网络数据*/
    [AFHTTP request:url completion:^(BOOL success, id _Nullable response, NSError * _Nullable error) {
        
        if(success) {
            [self updateThisUI:url JSON:response];
        }
    }];
}

- (void)updateThisUI:(NSString *)url JSON:(id)JSON {
    
    if(JSON == nil) {return;} //兼容检查

    _webResult = JSON;
    NSString *wbURL = [JSON objectForVitualKey:@"url"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wbURL] ] ];
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
    
    if([@[@"png", @"jpg", @"webp", @"gif"]
        containsObject:request.URL.absoluteString.pathExtension.lowercaseString]) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateWebTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateWebTitle];
    [_webView setWebViewHtmlFont];
    [_webView setWebViewHtmlProperty];
    [_loadingView stopAnimation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    contentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.dragging) {  // 拖拽
        if ((scrollView.contentOffset.y - contentOffsetY) > 10.0f) {  // 向上拖拽
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.navbar.sd_layout.yIs(-self.navbar.height);
                                 _webView.sd_layout.yIs(20).heightIs(self.view.height - 20.0);
                                 if(_hasToolbar) _toolbar.sd_layout.yIs(self.view.height);
                             }
                             completion:^(BOOL finished) {
                             }];
            
        } else if ((contentOffsetY - scrollView.contentOffset.y) > 10.0f) {   // 向下拖拽
            
            CGFloat toolbarH = (_hasToolbar ? _toolbar.height : 0.f);
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.navbar.sd_layout.yIs(0);
                                 _webView.sd_layout.yIs(self.navbar.height).heightIs(self.view.height - self.navbar.height - toolbarH );
                                 if(_hasToolbar) _toolbar.sd_layout.yIs(self.view.height - toolbarH);
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

    if(self.navbar.y != 0.0) {
        
        CGFloat toolbarH = (_hasToolbar ? _toolbar.height : 0.f);
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.navbar.sd_layout.yIs(0);
                             _webView.sd_layout.yIs(self.navbar.height).heightIs(self.view.height - self.navbar.height - toolbarH);
                             if(_hasToolbar) _toolbar.sd_layout.yIs(self.view.height - toolbarH);
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

@end
