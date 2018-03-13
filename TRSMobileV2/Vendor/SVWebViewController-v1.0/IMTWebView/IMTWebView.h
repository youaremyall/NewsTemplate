//
//  IMTWebView.h
//  webkittest
//
//  Created by Petr Dvorak on 11/23/11.
//  Copyright (c) 2011 Inmite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMTWebView : UIWebView

@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;
@property (nonatomic, copy)   void (^progressValueChanged)(CGFloat progress);
@property (nonatomic, copy)   void (^clickEvevnt)(NSDictionary *dictionary);

@end
