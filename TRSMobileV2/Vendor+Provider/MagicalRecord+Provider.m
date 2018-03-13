//
//  MagicalRecord+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/15.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "MagicalRecord+Provider.h"

@implementation MagicalRecordProvider

+ (void)load {
    
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:YES];
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static MagicalRecordProvider *instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init {
    
    if(self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    /*对MagicalRecord初始化*/
    [MagicalRecord setupCoreDataStack ];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    /*对MagicalRecord执行清理工作*/
    [MagicalRecord cleanUp];
}

@end
