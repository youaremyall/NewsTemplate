//
//  ShareSDK+Provider.h
//  TRSMobileV2
//
//  Created by  TRS on 16/3/7.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/SSDKImage.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"

@interface ShareSDK (ShareSDK_Provider)

/**
 * 显示分享菜单
 * @param content:分享内容
 * @param view:容器视图 (iPad版本分享所需)
 */
+ (void)showShareActionSheet:(NSDictionary * _Nonnull)dict inView:(UIView * _Nullable)view;

@end
