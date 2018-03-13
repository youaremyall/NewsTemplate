//
//  NSOfflineManager.m
//  TRSMobile
//
//  Created by TRS on 14-5-29.
//  Copyright (c) 2014年 TRS. All rights reserved.
//

#import "NSOfflineManager.h"
#import "IMTWebView.h"
#import "NSDictionary+Extension.h"
#import "StroageService+Provider.h"
#import "SDWebImageManager.h"
#import "AFHTTP+Provider.h"

//文档列表的顶部大图数据字段
#define kDocsTopicDatas     @"topic_datas"

//文档列表的列表数据字段
#define kDocsDatas          @"datas"

//文档列表的图片文件分隔符字段
#define kDocsImagesFiled    @","

@interface NSOfflineManager () <UIWebViewDelegate>

//用于下载网页html页面，及其网页内容图片，css样式文件，js脚本文件
@property (nonatomic, retain) IMTWebView     *webView;

//频道栏目（文档栏目）
@property (nonatomic, retain) NSMutableArray *arrayChannels;

//频道栏目（文档栏目）下的每个栏目文档列表
@property (nonatomic, retain) NSMutableArray *arrayDocs;

//频道栏目（文档栏目）下的每个栏目文档列表的图片文件及其网页html页面
@property (nonatomic, retain) NSMutableArray *arrayDocAppendixs;

//频道栏目名称
@property (nonatomic, retain) NSString  *channelName;

//频道栏目索引
@property (nonatomic, assign) int  indexChannel;

//文档列表索引
@property (nonatomic, assign) int  indexDoc;

//图片文件索引
@property (nonatomic, assign) int  indexDocAppendix;

//每个频道所占百分比
@property (nonatomic, assign) float channelPercent;

//每个文档所占百分比
@property (nonatomic, assign) float docPercent;

//当前下载进度百分比
@property (nonatomic, assign) float percent;

@end

@implementation NSOfflineManager

- (instancetype)init {
    
    if(self = [super init]) {
        
        _arrayChannels = [NSMutableArray arrayWithCapacity:0];
        _arrayDocs = [NSMutableArray arrayWithCapacity:0];
        _arrayDocAppendixs = [NSMutableArray arrayWithCapacity:0];
        
        _indexChannel = _indexDoc = _indexDocAppendix = -1;
        _channelPercent = _docPercent = _percent = 0.0;
        
        _webView = [[IMTWebView alloc] init];
        _webView.delegate = self;
    }
    return self;
}

- (NSArray *)subscribledChannels {

    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    NSArray *channels = [StroageService valueForKey:UserNewsChannel serviceType:serviceTypeUser];
    for(NSDictionary *dict in channels) {
        if([dict[isChannelSubscrible] boolValue]) {
            [arr addObject:dict];
        }
    }
    
    return arr;
}

#pragma mark -
//离线下载管理
- (void)offlineManagerDownloading:(BOOL)enable {
    
    self.cancelDownload = enable;
    if(self.cancelDownload) {NSLog(@"---------------------------离线阅读取消---------------------------\n\n"); return;}

    //获取栏目列表
    NSLog(@"---------------------------离线阅读开始---------------------------\n\n");
    [self resetOfflineManagerParams:0];
    NSArray *channels = [self subscribledChannels];
    [_arrayChannels addObjectsFromArray:channels];
    
    //加载每个栏目列表下的文档列表数据
    _channelPercent = 100 / _arrayChannels.count;
    [self loadChannelsDocs];
}

//加载栏目列表下的文档列表数据
- (void)loadChannelsDocs {
    
    if(self.cancelDownload) return;
    
    //栏目索引计数+1
    _indexChannel++;
   
    //判断栏目列表下的文档列表数据加载完成
    if(_indexChannel >= _arrayChannels.count) {
        _percent = 100;
        self.cancelDownload = YES;
        if(self.callback) {self.callback(self.channelName, _percent, YES);}
        NSLog(@"---------------------------离线阅读完成---------------------------\n\n");
        
    }
    else { //加载本栏目下的文档列表数据
        
        //获取本栏目的名称和链接url地址
        NSDictionary *channel = _arrayChannels[_indexChannel];
        self.channelName = [channel objectForVitualKey:@"title"];
        NSString *channelUrl  = [channel objectForVitualKey:@"url"];
        if([channelUrl rangeOfString:@".json"].location == NSNotFound) {
            channelUrl = [channelUrl stringByAppendingPathComponent:@"index.json"];
        }
        
        [AFHTTP request:channelUrl cachePolicy:cachePolicyYes completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {

            //上层界面更新进度
            if(self.callback) {self.callback(self.channelName, _percent, NO);}

            if(success) {
                NSLog(@"已下载文档列表：%@，%@", self.channelName, channelUrl);
                [self didLoadChannelsDocsFinish:response];
            }
            else {
                [self didLoadChannelsDocsFinish:[StroageService valueForKey:channelUrl serviceType:serviceTypeDefault] ];
            }
            
        }];
    }
}

//加载每个栏目下的文档列表数据
- (void)loadChannelsDocsLists {
    
    if(self.cancelDownload) return;

    //文档索引技术+1
    ++_indexDoc;
    
    //判断每个栏目的文档列表数据加载完成
    if(_indexDoc >= _arrayDocs.count) { //加载下一栏目文档列表数据
        
        [self loadChannelsDocs];
    }
    else { //下载文档列表中的图片字段附件和文档对应的细览数据
        
        _percent += _docPercent;
        if(self.callback) {self.callback(self.channelName, _percent, NO);}
        NSLog(@"+++++++++++++++++++++++++++离线进度：%0.2f++++++++++++++++++++++++++", _percent);

        //预处理文档列表的图片文件
        [self resetOfflineManagerParams:2];
        NSArray *images = [self appendixsFromDoc:_arrayDocs[_indexDoc] ];
        [_arrayDocAppendixs addObjectsFromArray:images];

        //下载图片字段附件和文档细览数据
        [self loadChannelDocAppendix];
    }
}

//下载每个栏目的文档列表数据附件
- (void)loadChannelDocAppendix {
    
    if(self.cancelDownload) return;

    //图片附件索引+1
    ++_indexDocAppendix;
    
    //判断文档列表的图片附件加载完成
    if(_indexDocAppendix >= _arrayDocAppendixs.count) { //加载完成时，加载文档细览数据
        
        NSString *docUrl = [_arrayDocs[_indexDoc] objectForVitualKey:@"url"];
        NSLog(@"已下载文档细览：%@", docUrl);
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:docUrl]] ];
    }
    else { //下载文档列表的图片字段附件
        
        SDWebImageDownloaderProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            float progress = (receivedSize * 100 / expectedSize);
            if(progress == 100) {
                NSLog(@"已下载图片：%@", targetURL.absoluteString);
            }
        };
        
        SDWebImageDownloaderCompletedBlock completedBlock = ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            
            [self loadChannelDocAppendix];
        };
        
        NSString *imageUrl = _arrayDocAppendixs[_indexDocAppendix];
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl]
                                                                        options:SDWebImageDownloaderLowPriority
                                                                       progress:progressBlock
                                                                      completed:completedBlock];
    }
}

//加载栏目列表下的文档列表数据完成处理
- (void)didLoadChannelsDocsFinish:(id)JSON {
    
    //判断本栏目列表下有无文档列表数据
    if(JSON == nil || [JSON count] == 0) { //没有文档列表时，加载下一栏目文档列表数据
        
        NSLog(@"#########本栏目无文档列表数据!#########");
        _percent += _channelPercent;
        if(self.callback) {self.callback(self.channelName, _percent, NO);}
        NSLog(@"+++++++++++++++++++++++++++离线进度：%0.2f++++++++++++++++++++++++++", _percent);
        
        [self loadChannelsDocs];
    }
    else { //有文档列表时
        
        //重置文档列表数据和索引位
        [self resetOfflineManagerParams:1];
        
        //预处理文档列表数据
        if([JSON isKindOfClass:[NSArray class]]) {
            [_arrayDocs addObjectsFromArray:JSON];
        }
        else if([JSON isKindOfClass:[NSDictionary class]]) {
            [_arrayDocs addObjectsFromArray:JSON[kDocsTopicDatas] ];
            [_arrayDocs addObjectsFromArray:JSON[kDocsDatas] ];
        }

        //下载文档列表中的图片字段附件和文档对应的细览数据
        _docPercent = _channelPercent / _arrayDocs.count;
        [self loadChannelsDocsLists];
    }
}

//根据文档列表数据的词典获取所有图片字段附件
- (NSArray *)appendixsFromDoc:(NSDictionary *)doc{
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    id images = [doc objectForVitualKey:@"image"];
    if([images isKindOfClass:[NSArray class] ]) { //文档列表的图片字段，返回实际为数组时
        for(id obj in images) {
            if([obj isKindOfClass:[NSString class]]) {
                [array addObject:obj];
            }
            else if([obj isKindOfClass:[NSDictionary class]]) {
                [array addObject:[obj objectForVitualKey:@"image"]  ];
            }
        }
    }
    else if([images isKindOfClass:[NSString class]]) {
        NSArray *arr = [images componentsSeparatedByString:kDocsImagesFiled];
        [array addObjectsFromArray:arr];
    }
    
    return array;
}

//重置离线管理参数
- (void)resetOfflineManagerParams:(int)param {
    
    switch (param) {
        case 0: //频道栏目
            _indexChannel = -1;
            [_arrayChannels removeAllObjects];
            break;
        case 1: //栏目的文档列表
            _indexDoc = -1;
            [_arrayDocs removeAllObjects];
            break;
        case 2: //文档列表的图片文件及其网页html页面
            _indexDocAppendix = -1;
            [_arrayDocAppendixs removeAllObjects];
            break;
        default:
            break;
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //加载下一栏目文档列表数据
    [self loadChannelsDocsLists];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    //加载下一栏目文档列表数据
    [self loadChannelsDocsLists];
}

@end
