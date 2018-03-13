//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <UIKit/UIKit.h>
#import "UIBaseViewController.h"
#import "UMAnalytics+Provider.h"
#import "IMTWebView.h"

@interface SVWebViewController : UIBaseViewController

- (instancetype)initWithURL:(NSString *)URL;

@property (nonatomic, strong) IMTWebView  *webView;
@property (assign, nonatomic) BOOL  isInset;
@property (nonatomic, weak) id<UIWebViewDelegate> delegate;

@end
