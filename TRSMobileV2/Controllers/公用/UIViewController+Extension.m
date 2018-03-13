//
//  UIViewController+Block.m
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2016/12/31.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "UIViewController+Extension.h"
#import "UIHtmlDetailViewController.h"
#import "UIImagesDetailViewController.h"
#import "UIVideoPlayerViewController.h"
#import "UIMusicPlayerViewController.h"
#import "SVWebViewController.h"
#import "Globals.h"

@implementation UIViewController (UIViewController_Extension)

/**
 * @brief 根据传入参数返回容器中视图的类名
 * @param dict : 数据字典
 * @param index : 索引值
 * @return 视图类名
 */
- (NSString* _Nonnull)getVCClassName:(NSDictionary * _Nonnull)dict index:(NSInteger)index {

    NSInteger type = [dict[@"channelType"] integerValue];
    switch (type) {
        case 5:
        case 6:
            return @"UIGridViewController";
        case 7:
            return @"SVWebViewController";
        default:
            return @"UIListViewController";
    }
}

/**
 * @brief 根据传入数据返回cell标识符
 * @param dict : 数据字典
 * @return cell标识符
 */
- (NSString * _Nonnull)getVCCellIdentifier:(NSDictionary * _Nonnull)dict {

    NSInteger type = [dict[@"channelType"] integerValue];
    switch (type) {
        case 2:
            return @"UINewsPhotoCell";
        case 3:
            return @"UINewsAudioCell";
        case 4:
            return @"UINewsVideoCell";
        case 5:
        case 6:
            return @"UINewsGridCell";
        default:
            break;
    }
    
    NSArray *images = dict[@"RelPhoto"];
    if([dict[@"imgstyle"] integerValue] == 1) {
        return @"UINewsLargeImageCell";
    }
    if(images.count > 1) {
        return @"UINewsImagesCell";
    }
    return @"UINewsNormalCell";
}

/**
 * @brief 根据传入的字典参数决定页面跳转逻辑
 * @param dict: 数据字典
 * @retuen 无
 */
- (void)handleVCClickEvent:(NSDictionary * _Nonnull)dict {
    
    NSInteger vcValue = -1;
    id clickType = dict[@"clickType"];
    if(!clickType) {
        vcValue = [dict[@"RelPhoto"] count] > 1 ? clickTypeGallery : clickTypeDefault;
    }
    else {
        vcValue = [clickType integerValue];
    }
    
    switch (vcValue) {
            
        case clickTypeWeb:
        {
            SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:[dict objectForVitualKey:@"url"] ];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        case clickTypeDefault:
        {
            UIHtmlDetailViewController *vc = [[UIHtmlDetailViewController alloc] init];
            vc.dict = dict;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        case clickTypeGallery:
        {
            UIImagesDetailViewController *vc = [[UIImagesDetailViewController alloc] init];
            vc.dict = dict;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        
        case clickTypeMusic:
        {
            UIMusicPlayerViewController  *vc = [UIMusicPlayerViewController sharedInstance];
            vc.dict = dict;
            [self presentViewController:vc animated:YES completion:^(){}];
            break;
        }

        case clickTypeVideo:
        {
            UIVideoPlayerViewController *vc = [[UIVideoPlayerViewController alloc] init];
            vc.dict = dict;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        default:
            break;
    }
}

/**
 * @brief 处理页面事件点击行为
 * @param dict: 数据字典
 * @param event : 点击行为
 * @return 无
 */
- (void)handleVCActionEvent:(NSDictionary *_Nonnull)dict action:(actionType)action completioncompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion {

}

/**
 * @brief 同步文章属性统计数据
 * @param docId : 文章Id
 * @param docType : 文章类型
 * @param action : 操作类型
 * @param completin : 回调
 * @return 无
 */
- (void)syncDocAnalytics:(NSString * _Nonnull)docId action:(actionType)action completion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion {

    //兼容性检查
    if(!docId || [docId isKindOfClass:[NSNull class]] || [docId isEqualToString:@""]) return;
    
    NSArray *actions = @[@{@"readCount" : @"readUsers"},
                         @{@"likeCount" : @"likeUsers"},
                         @{@"unLikeCount" : @"unLikeUsers"},
                         @{@"favoriteCount" : @"favoriteUsers"},
                         @{@"playCount" : @"playUsers"},
                         @{@"shareCount" : @"shareUsers"},
                         ];
    
    AVQuery *query = [AVQuery queryWithClassName:@"DocAnalytics"];
    [query whereKey:@"docId" equalTo:docId ];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSString *key = [actions[action] allKeys][0];
        NSString *value = [actions[action] allValues][0];
        
        AVObject *object = nil;
        if(!objects.count) {
            object = [AVObject objectWithClassName:@"DocAnalytics" dictionary:@{@"docId" : docId, key : @(0)}];
        }
        else {
            object = objects[0];
        }
        
        AVUser *user = [AVUser currentUser];
        if(user) {[object addUniqueObject:user forKey:value];}
        
        // 原子增加查看的次数
        [object incrementKey:key];
        
        // 保存时自动取回云端最新数据
        object.fetchWhenSave = true;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(completion) {completion(succeeded, error); }
        }];
    }];
}

@end
