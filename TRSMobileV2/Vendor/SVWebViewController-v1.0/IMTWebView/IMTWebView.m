//
//  IMTWebView.m
//  webkittest
//
//  Created by Petr Dvorak on 11/23/11.
//  Copyright (c) 2011 Inmite. All rights reserved.
//

#import "IMTWebView.h"
#import "UIView+Extension.h"
#import "UIWebView+Extension.h"
#import "NSDictionary+Extension.h"
#import "RNCachingURLProtocol.h"

@interface UIWebView () <UIGestureRecognizerDelegate>

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end

@implementation IMTWebView

@synthesize resourceCount;
@synthesize resourceCompletedCount;

- (instancetype) init {

    if(self = [super init]) {
        
        [self disableOutOfBoundaryShadow];
        [self addTapGesture:self selector:@selector(tapGestureRecognizer:)];
        self.gestureRecognizers[0].delegate = self;
        
        [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    }
    return self;
}

- (void)dealloc {
    
    [NSURLProtocol unregisterClass:[RNCachingURLProtocol class]];
}

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    return [NSNumber numberWithInt:resourceCount++];
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource {
    [super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    resourceCompletedCount++;
    if(_progressValueChanged) {
        _progressValueChanged(resourceCompletedCount/resourceCount);
    }
    
    if (resourceCompletedCount == resourceCount) {
        self.resourceCount = 0;
        self.resourceCompletedCount = 0;
    }
}

-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    resourceCompletedCount++;
    if(_progressValueChanged) {
        _progressValueChanged(resourceCompletedCount/resourceCount);
    }
    
    if (resourceCompletedCount == resourceCount) {
        self.resourceCount = 0;
        self.resourceCompletedCount = 0;
    }
}

#pragma mark - UIGestureRecognizer
- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognzier {

    if (recognzier.state == UIGestureRecognizerStateEnded) {
        
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"webscript.js"];
        NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [self stringByEvaluatingJavaScriptFromString:script];
        
        CGPoint point = [recognzier locationInView:self];
        
        //// Get the URL link at the touch location
        NSString *function = [NSString stringWithFormat:@"script.getElement(%f,%f);", point.x, point.y];
        NSString *result = [self stringByEvaluatingJavaScriptFromString:function];
        
        if(result != nil && result.length != 0) {
            NSDictionary *dict = [NSDictionary dictionaryFromJSONString:result];
            if(_clickEvevnt) {_clickEvevnt(dict);}
        }
        recognzier.view.accessibilityActivationPoint = point;
    }
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end

