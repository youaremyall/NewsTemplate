//
//  ShareSDK+Provider.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/7.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "ShareSDK+Provider.h"
#import "SDImageCache.h"
#import "SVProgressHUD.h"
#import "UIImage+Extension.h"
#import "NSDictionary+Extension.h"

@implementation ShareSDK (ShareSDK_Provider)


+ (void)load {
    
    [self performSelectorOnMainThread:@selector(__init) withObject:nil waitUntilDone:NO];
}

+ (void)__init{
    
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeWechat)
                            ,@(SSDKPlatformTypeQQ)
                            ,@(SSDKPlatformTypeSinaWeibo)
                            /*,@(SSDKPlatformTypeMail)
                            ,@(SSDKPlatformTypeSMS)
                            ,@(SSDKPlatformTypeCopy)*/]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                        
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                             
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                             
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:valueForDictionaryFile(@"Vendor")[@"SinaWeiboAppKey"]
                                                appSecret:valueForDictionaryFile(@"Vendor")[@"SinaWeiboAppSecret"]
                                              redirectUri:valueForDictionaryFile(@"Vendor")[@"SinaWeiboRedirectUri"]
                                                 authType:SSDKAuthTypeBoth];
                      break;
                      
                  case SSDKPlatformTypeWechat:
                      //设置微信应用信息
                      [appInfo SSDKSetupWeChatByAppId:valueForDictionaryFile(@"Vendor")[@"WeChatAppId"]
                                            appSecret:valueForDictionaryFile(@"Vendor")[@"WeChatAppSecret"]];
                      break;
                  case SSDKPlatformTypeQQ:
                      //设置QQ应用信息，其中authType设置为只用SSO形式授权
                      [appInfo SSDKSetupQQByAppId:valueForDictionaryFile(@"Vendor")[@"QQAppId"]
                                           appKey:valueForDictionaryFile(@"Vendor")[@"QQAppKey"]
                                         authType:SSDKAuthTypeSSO];
                      break;
                      
                  default:
                      break;
              }
          }];
}

/**
 * 显示分享菜单
 * @param content:分享内容
 * @param view:容器视图 (iPad版本分享所需)
 */

+ (void)showShareActionSheet:(NSDictionary *)dict inView:(UIView *)view {
    
    //创建分享参数(必要)
    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传image参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    
    //分享内容地址、标题、内容
    NSString *_url = [dict objectForVitualKey:@"url"];
    if(_url == nil || [@"" isEqualToString:_url]) { [SVProgressHUD showErrorWithStatus:@"分享地址不存在"]; return;}
    NSString *_title = [dict objectForVitualKey:@"title"];
    NSString *_content = [dict objectForVitualKey:@"content"];
    
    //获取图片数据
    id _image = [dict objectForVitualKey:@"image"];
    while (_image && ![_image isKindOfClass:[NSString class]]) {
        
        if([_image isKindOfClass:[NSDictionary class]] && [_image count]) {
            _image = [_image objectForVitualKey:@"image"];
        }
        if([_image isKindOfClass:[NSArray class]] && [_image count]) {
            _image = _image[0];
        }
    }
    
    //处理分享内容
    if(_content == nil || [@"" isEqualToString:_content]) {
        _content = [NSString stringWithFormat:@"分享自%@", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"]];
    }
    
    //处理分享图片
    if(_image == nil || [@"" isEqualToString:_image]) {
        /*若图片字段没有，则采用本地的Icon图标.*/
        _image = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"AppIcon60x60@2x.png"];
    }
    
    /*处理图片对于微信分享的大小限制
    2016-11-21 吴建军增加 针对微信分享图片限制大小为32K, 超出时点击分享无反应的问题处理
     (解决方法为：1. 先从内存加载判断图片的大小； 2. 若图片大于32K, 则缩放图片到满足微信分享的规则;
     3. 对于满足分享规则的图片，采用图片地址传值，不满足分享规则的图片，则直接传入UIImage对象。)
     */
    UIImage *__image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_image];
    BOOL isExceed = (1/*32*/ * 1024 < __image.size.width * __image.size.height);
    if(isExceed) {
        __image = [__image scaleImageWithSize:CGSizeMake(360, 200)];
    } /*增加结束*/
    
    
    //构造分享所需参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionaryWithDictionary:dict];
    [shareParams SSDKEnableUseClientShare];
    
    //构造分享内容
    [shareParams SSDKSetupShareParamsByText:_content
                                     images:(!isExceed ? _image : __image)
                                        url:[NSURL URLWithString:_url]
                                      title:_title
                                       type:SSDKContentTypeAuto];
    
    //针对新浪微博单独配置
    [shareParams SSDKSetupSinaWeiboShareParamsByText:[NSString stringWithFormat:@"%@%@", _title, _url]
                                               title:_title
                                              images:(__image)
                                               video:nil
                                                 url:[NSURL URLWithString:_url]
                                            latitude:0
                                           longitude:0
                                            objectID:@""
                                      isShareToStory:NO
                                                type:SSDKContentTypeImage];
    
    //将要自定义顺序的平台传入items参数中
    NSArray *items = @[/*,@(SSDKPlatformTypeWechat) 此处不用微信平台是需要去掉默认显示微信收藏*/
                       @(SSDKPlatformSubTypeWechatSession)
                       ,@(SSDKPlatformSubTypeWechatTimeline)
                       ,@(SSDKPlatformTypeQQ)
                       ,@(SSDKPlatformTypeSinaWeibo)
                       /*,@(SSDKPlatformTypeMail)
                       ,@(SSDKPlatformTypeSMS)
                       ,@(SSDKPlatformTypeCopy)*/];
    
    //弹出ShareSDK分享菜单
    [SSUIShareActionSheetStyle setShareActionSheetStyle:ShareActionSheetStyleSimple];
    SSUIShareActionSheetController * sheet = [ShareSDK showShareActionSheet:view
                             items:items /*(分享菜单)平台顺序自定义*/
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {

                   switch (state) {
                           
                       case SSDKResponseStateSuccess:
                           [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                           break;
                           
                       case SSDKResponseStateFail:
                           NSLog(@"分享失败 : %@", error.userInfo);
                           [SVProgressHUD showErrorWithStatus:@"分享失败"];
                           break;
                           
                       default:
                           break;
                   }
               }];
    
    //取消微博分享弹出的中间编辑页面
    [sheet.directSharePlatforms addObjectsFromArray:@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformTypeTencentWeibo)]];
}

@end
