//
//  UIViewController+Extension.h
//  TRSMobileV2
//
//  Created by 廖靖宇 on 2016/10/31.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//列表显示样式
typedef NS_ENUM(NSInteger, docType) {
    
    docTypeNormal = 0,              //仅标题
    docTypeNormalPicLeft,           //标题 + 左侧图片
    docTypeNormalPicRight,          //标题 + 右侧图片
    docTypeImages2Equal,            //上标题 + 固定高度二张图片均分
    docTypeImages3Equal,            //上标题 + 固定高度三张图片均分
    docTypeImagesLargeFix,          //上标题 + 固定高度图片
    docTypeImagesLargeAuto,         //上标题 + 自动高度图片
    docTypeImagesLeft2Small,        //上标题 + 左侧两张固定高度图片 + 右侧一张图片，
    docTypeImagesRight2Small,       //上标题 + 左侧一张图片 + 右侧两张固定高度图片
};

//文章详情细览类型
typedef NS_ENUM(NSInteger, clickType) {

    clickTypeWeb = 0,               //外链网页
    clickTypeDefault,               //文章
    clickTypeGallery,               //图集
    clickTypeMusic,                 //音乐
    clickTypeVideo,                 //视频
};

//用户操作行为
typedef NS_ENUM(NSInteger, actionType) {
    
    actionTypeRead = 0,             //阅读
    actionTypeLike,                 //点赞
    actionTypeUnLike,               //点踩
    actionTypeComment,              //评论
    actionTypeFavorite,             //收藏
    actionTypePlay,                 //播放
    actionTypeShare,                //分享
};

@interface UIViewController (UIViewController_Extension)

/**
 * @brief 根据传入参数返回容器中视图的类名
 * @param dict : 数据字典
 * @param index : 索引值
 * @return 视图类名
 */
- (NSString* _Nonnull)getVCClassName:(NSDictionary * _Nonnull)dict index:(NSInteger)index;

/**
 * @brief 根据传入数据返回cell标识符
 * @param dict : 数据字典
 * @return cell标识符
 */
- (NSString * _Nonnull)getVCCellIdentifier:(NSDictionary * _Nonnull)dict;

/**
 * @brief 根据传入的字典参数决定页面跳转逻辑
 * @param dict: 数据字典
 * @retuen 无
 */
- (void)handleVCClickEvent:(NSDictionary * _Nonnull)dict;

/**
 * @brief 处理页面事件点击行为
 * @param dict: 数据字典
 * @param event : 点击行为
 * @return 无
 */
- (void)handleVCActionEvent:(NSDictionary *_Nonnull)dict action:(actionType)action completioncompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion;

/**
 * @brief 同步文章属性统计数据
 * @param docId : 文章Id
 * @param docType : 文章类型
 * @param action : 操作类型
 * @param completin : 回调
 * @return 无
 */
- (void)syncDocAnalytics:(NSString * _Nonnull)docId action:(actionType)action completion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion;

@end

