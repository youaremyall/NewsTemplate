//
//  EventInfo.h
//  SDKDemo
//
//  Created by 张张凯 on 17/6/15.
//  Copyright © 2017年 zhangkai. All rights reserved.


#import <Foundation/Foundation.h>

@interface EventInfo : NSObject
//一下四个是必传信息
@property (nonatomic,retain) NSString *eventCode;   //动作  如：分享，传编码：A0022
@property (nonatomic,retain) NSString *objectType;  //对象类型  如：新闻传编码值C01
@property (nonatomic,retain) NSString *objectID;    //对象ID  文章ID
@property (nonatomic,retain) NSString *classifyID;  //分类ID  该操作发生在哪个栏目，该栏目（频道）的ID  如果该业面没有栏目ID则不传值    如头条栏目ID：123


//下面是选填信息
@property (nonatomic,retain) NSString *pageType;    //界面种类     如：个人设置页、列表页、启动页等
@property (nonatomic,retain) NSString *classifyName;//分类短名称    该操作行为发生在哪个栏目下，该栏目（频道的短名称） 如：推荐、头条、杭州
@property (nonatomic,retain) NSString *eventName;   //事件名称  如：点赞
@property (nonatomic,retain) NSString *eventDetail; //动作细化  是对eventCode的细化，如分享的细化是分享到“微信、朋友圈”
@property (nonatomic,retain) NSString *search;      //搜索词  搜索的词



@property (nonatomic,retain) NSString *number;      //数量，被操作对象的某个序号指标，如：文章字数
@property (nonatomic,retain) NSString *objectName;  //对象短名称，如：文章标题
@property (nonatomic,retain) NSString *objectIDs;   //对象IDs  统计列表中多个文章的ID时传值
@property (nonatomic,retain) NSString *sequence;    //序数，被操作对象的某个序号指标，如：打开文章阅读页时，所选文章是列表上的第几篇。
@property (nonatomic,retain) NSString *percentage;  //本次操作行为百分比，如：阅读百分比
@property (nonatomic,assign) BOOL isSuccess;   //是否成功，默认成功 如：登录成功
@property (nonatomic,retain) NSString *otherInfo;   //其他信息    

@property (nonatomic,retain) NSString *visitTime;   //无需开发者调用


@end
