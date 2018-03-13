//
//  AppDelegate.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/7.
//  Copyright © 2016年 liaojingyu. All rights reserved.
//

#import "AppDelegate.h"
#import "Globals.h"

@interface AppDelegate () <JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [UIViewController new];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [UILaunchViewController sharedInstance].willEnterAppBlock = ^{
        
        [self setAppMainWindowUI];
    };

    [UILaunchViewController sharedInstance].clickEvent = ^(NSDictionary *dict, NSInteger index) {
        /*在此处理启动广告点击事件*/
        NSLog(@"点击广告了!!!");
    };
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {

    NSString* prefix = @"iOSWidgetApp://action=";
    if ([[url absoluteString] rangeOfString:prefix].location != NSNotFound) {
        
        NSString* action = [[url absoluteString] substringFromIndex:prefix.length];
        if ([action isEqualToString:@"openAPP"]) {
            //打开APP
        }
        else if([action containsString:@"openNews"]) {
            
            //进入细览            
        }
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {

    // 必须的
    NSLog(@"注册推送通知设备:%@", deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"注册推送通知失败，error : %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {

    NSLog(@"接收推送通知: %@", userInfo);
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    [self application:application alertWithReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    //iOS7以后收到推送 推送结果会在这里响应
    //iOS10 以后不再响应这里
    
    NSLog(@"接收推送通知: %@", userInfo);
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    [self application:application alertWithReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {

}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [JPUSHService resetBadge];
        ///在前台时候收到推送 iOS10App运行在前台推送来了也能显示哦
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService resetBadge];
        ///这个是我自己处理推送的方法 忽略掉
        [self application:[UIApplication sharedApplication] alertWithReceiveRemoteNotification:userInfo];
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
#endif

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 页面设置

- (void)setAppMainWindowUI {

    id completion = ^(BOOL success, id _Nullable response, NSError * _Nullable error) {
        
        NSMutableArray *vcs = [NSMutableArray arrayWithCapacity:0];
        for(NSDictionary *dict in response) {
            id vc = [NSClassFromString(dict[@"class"]) new];
            [vc setDict:dict];
            [vcs addObject:vc];
        }
        
        RDVTabBarController *rdvTab = [RDVTabBarController new];
        rdvTab.viewControllers = vcs;
        [rdvTab setTabBarHidden:(vcs.count <=1) animated:YES];
        
        UIColor *colorN = [UIColor colorWithRGB:0x929292];
        UIColor *colorH = [UIColor colorWithRGB:UIColorThemeDefault];
        
        NSInteger i = 0;
        for(RDVTabBarItem *item in rdvTab.tabBar.items) {
            NSDictionary *dict = response[i++];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"normal.bundle/%@", dict[@"icon"]] ];
            item.title = dict[@"title"];
            item.unselectedTitleAttributes = @{NSForegroundColorAttributeName : colorN};
            item.selectedTitleAttributes = @{NSForegroundColorAttributeName : colorH};
            [item setSelectedImage:[image colorImage:colorH] withUnselectedImage:[image colorImage:colorN] ];
        }

        //中间窗格
        _navTab = [[UIAnimationNavigationController alloc] initWithRootViewController:rdvTab];
        [_navTab setNavigationBarHidden:YES animated:YES];
        
        //左侧滑
        UIViewController *vcLeft = [UIViewController new];
        UINavigationController *navLeft = [[UINavigationController alloc] initWithRootViewController:vcLeft];
        vcLeft.view.backgroundColor = [UIColor colorRandomWithAlpha:0.8];

        //右侧滑
        UIViewController *vcRight = [UIViewController new];
        UINavigationController *navRight = [[UINavigationController alloc] initWithRootViewController:vcRight];
        vcRight.view.backgroundColor = [UIColor colorRandomWithAlpha:0.8];

        //侧滑组件
        _vcDrawer = [MSDynamicsDrawerViewController new];
        _vcDrawer.paneViewSlideOffAnimationEnabled = NO;
        _vcDrawer.shouldAlignStatusBarToPaneView = NO;
        
        id <MSDynamicsDrawerStyler> parallaxStyler = [MSDynamicsDrawerFadeStyler styler];
        [_vcDrawer setRevealWidth:([UIScreen mainScreen].bounds.size.width - 80) forDirection:(MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionRight)];
        [_vcDrawer addStyler:parallaxStyler forDirection:(MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionRight)];
        [_vcDrawer setPaneViewController:_navTab animated:YES completion:^(void){}];
        [_vcDrawer setDrawerViewController:navLeft forDirection:MSDynamicsDrawerDirectionLeft];
        [_vcDrawer setDrawerViewController:navRight forDirection:MSDynamicsDrawerDirectionRight];
        
        //设置侧滑组件为主视窗根视图,可以滑动内容及边缘pop
        self.window.rootViewController = _vcDrawer;
    };
    
    [AFHTTP request:LayoutTop completion:completion];
}

#pragma mark - 推送通知
- (void)application:(UIApplication *)application alertWithReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive) {
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NoticicationTitle", nil)
                                                                    message:[userInfo valueForKeyPath:@"aps.alert"]
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NoticicationIngore", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [vc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NoticicationLook", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self receiveRemoteNotificationHandle:userInfo];
        }]];
        [self.window.rootViewController presentViewController:vc animated:YES completion:^(void){}];
    }
    else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        [dict setObject:[userInfo valueForKeyPath:@"aps.alert"] forKey:@"title"];
        [self receiveRemoteNotificationHandle:dict];
    }
}

- (void)receiveRemoteNotificationHandle:(NSDictionary *)dictionary {

}

@end
