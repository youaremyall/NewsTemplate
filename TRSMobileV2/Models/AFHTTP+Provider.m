//
//  AFHTTP+Provider.m
//  TRSMobileV2
//
//  Created by  廖靖宇 on 16/3/16.
//  Copyright © 2016年  liaojingyu. All rights reserved.
//

#import "AFHTTP+Provider.h"
#import "StroageService+Provider.h"
#import "NSString+Extension.h"
#import "XMLParser.h"

#define HTTPRequestSuffix   @"lmt.txt"      //时间戳文件后缀名
#define URITimestamp        @"timestamp"    //存放在NSUserDefaults中的键

static BOOL isLoadTip;
AFNetworkReachabilityStatus statusAFNetworkReachability;

@implementation AFHTTP

+ (void)initialize {
    
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (instancetype)sharedInstance {
    
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if(self = [super init]) {
        
        isLoadTip = YES;
        statusAFNetworkReachability = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        [self setReachabilityStatusChangeBlock];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    }
    return self;
}

- (void)setReachabilityStatusChangeBlock {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        statusAFNetworkReachability = status;
        NSLog(@"当前网络链接状态 : %@", [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString]);
        
        if(isLoadTip) {
            if(status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                isLoadTip = NO;
                return;
            }
            isLoadTip = NO;
        }
        
        NSString *locailzedDescprition = nil;
        UIImage *image = nil;
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                locailzedDescprition = @"当前已连接到数据网络";
                image = [UIImage imageNamed:@"normal.bundle/网络连接_成功.png"];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                locailzedDescprition = @"当前已连接到WiFi";
                image = [UIImage imageNamed:@"normal.bundle/网络连接_成功.png"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                locailzedDescprition = @"网络不给力，请检查网络设置";
                image = [UIImage imageNamed:@"normal.bundle/网络连接_失败.png"];
                break;
            default:
                locailzedDescprition = @"网络连接状态未知";
                image = [UIImage imageNamed:@"normal.bundle/网络连接_失败.png"];
                break;
        }
        
        [[XZMStatusBarHUD sharedInstance] showMessage:locailzedDescprition
                                                image:image
                                             position:0
                                           animaDelay:0
                                        configuration:^{
                                            [XZMStatusBarHUD sharedInstance].statusH = 64.0;
                                            [XZMStatusBarHUD sharedInstance].statusColor = [UIColor colorWithRed:(28/255.0) green:(147/255.0) blue:(207/255.0) alpha:1.0];
                                        }];
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark -

+ (void)request:(NSString * _Nonnull)url
     completion:(completion _Nullable)completion {

    [self request:url
           method:@"GET"
       parameters:nil
      compareType:compareTypeNone
      cachePolicy:cachePolicyNone
         progress:nil
       completion:completion];
}

+ (void)request:(NSString * _Nonnull)url
    cachePolicy:(cachePolicy)cachePolicy
     completion:(completion _Nullable)completion {

    [self request:url
           method:@"GET"
       parameters:nil
      compareType:compareTypeNone
      cachePolicy:cachePolicy
         progress:nil
       completion:completion];
}

+ (void)request:(NSString * _Nonnull)url
         method:(NSString * _Nonnull)method
     parameters:(NSDictionary * _Nullable)parameters
       progress:(progress _Nullable)progress
     completion:(completion _Nullable)completion {

    [self request:url
           method:method
       parameters:parameters
      compareType:compareTypeNone
      cachePolicy:cachePolicyNone
         progress:progress
       completion:completion];
}

+ (void)request:(NSString * _Nonnull)url
         method:(NSString * _Nonnull)method
     parameters:(NSDictionary * _Nullable)parameters
    compareType:(compareType)compareType
    cachePolicy:(cachePolicy)cachePolicy
       progress:(progress _Nullable)progress
     completion:(completion _Nullable)completion {
    
    //由于传入的url地址定义为 _Nonull， 此处就无需做兼容性检查判断合法.
    
    //检测当前网络环境是否可用
    if(statusAFNetworkReachability == AFNetworkReachabilityStatusNotReachable
       && ![self isLocalFileRequest:url]) {
        
        NSLog(@"网络不给力，请检查网络设置");
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorNotConnectedToInternet
                                         userInfo:@{NSLocalizedFailureReasonErrorKey : @"网络不可用，请设置网络设置",
                                                    NSLocalizedDescriptionKey : @"网络不给力，请检查网络设置",
                                                    NSLocalizedRecoverySuggestionErrorKey : @"请检查网络设置"}];
        if(completion) {completion(NO, nil, error);};
        return;
    }

    //判断是否加载本地文件
    if([self isLocalFileRequest:url]) {
        
        [self requestLocalFile:url
                       completion:completion];
    }
    else {
        
        //判断文件请求时的比较类型
        if(compareTypeNone == compareType) {
            [self request:url
                   method:method
               parameters:parameters
                timestamp:nil
              cachePolicy:cachePolicy
                 progress:progress
               completion:completion];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            });

            NSString *url_lmt = nil; //时间戳文件访问地址 (添加随机数避免网络缓存)
            if(compareTypeOverview == compareType) {
                url_lmt = [NSString stringWithFormat:@"%@/%@?%d", [url stringByDeletingLastPathComponent], HTTPRequestSuffix,  (int)(random()%10000)];
            }
            else {
                url_lmt = [NSString stringWithFormat:@"%@_%@?%d", [url stringByDeletingPathExtension], HTTPRequestSuffix, (int)(random()%10000)];
            }
            
            //请求时间戳文件
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer new];
            
            id __progress = ^(NSProgress * _Nonnull _progress) {
                
                float _progress_ = (_progress.completedUnitCount * 100 / _progress.totalUnitCount);
                NSLog(@"时间戳文件下载百分比 : %0.00f%%", _progress_);
                
                if(progress) {progress(_progress_);}
            };
            
            id __success = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSLog(@"时间戳文件请求成功 : %@ --> %ld", task.response.URL.absoluteString, ((NSHTTPURLResponse *)task.response).statusCode);
                
                if([responseObject isKindOfClass:[NSData class] ]) {
                    
                    NSString *timestamp = [NSString stringFromUTF8Data:responseObject];
                    
                    BOOL isEmpty  = (!timestamp || [timestamp isEqualToString:@""]);
                    BOOL isUpdate = [self isUpdate:timestamp uri:url isWritten:NO];
                    
                    if(isEmpty
                       || isUpdate) {
                        
                        NSLog(@"时间戳文件失效或已更新(从原地址加载数据) : %@", task.response.URL.absoluteString);
                        [self request:url
                               method:method
                           parameters:parameters
                            timestamp:[NSString stringWithFormat:@"%0.00f", [NSDate date].timeIntervalSince1970]
                          cachePolicy:cachePolicy
                             progress:progress
                           completion:completion];
                    }
                    else { //时间戳未更新，告知上层
                        
                        NSError *error = [NSError errorWithDomain:NSGlobalDomain
                                                             code:-100
                                                         userInfo:@{NSLocalizedDescriptionKey : @"时间戳文件已是最新"}];
                        NSLog(@"时间戳文件已是最新 : %@, error : %@",task.response.URL.absoluteString, error.localizedDescription);
                        if(completion) {completion(NO, nil, error);}
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
            };
            
            id __failure = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                NSLog(@"时间戳文件访问出错(从原地址加载数据) : %@, error : %@", task.response.URL.absoluteString, error.localizedDescription);
                
                [self request:url
                       method:method
                   parameters:parameters
                    timestamp:[NSString stringWithFormat:@"%0.00f", [NSDate date].timeIntervalSince1970]
                  cachePolicy:cachePolicy
                     progress:progress
                   completion:completion];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
            };
            
            //Creates and runs an `NSURLSessionDataTask` with a `GET` request.
            [manager GET:url_lmt
              parameters:nil
                progress:__progress
                 success:__success
                 failure:__failure];
        }
    }
}

#pragma mark - 数据请求

/**
 * 根据url地址请求数据 (真正从服务器请求获取数据)
 * @param url : 请求url地址
 * @param method : 数据方式，在如下常用的GET、POST中选择，默认为GET
 * @param parameters : 传入POST body的参数，需为NSDictionary类型
 * @param timestamp : 时间戳
 * @param cachePolicy : 数据缓存策略
 * @param progress : 进度回调
 * @param completion : 回调函数
 * @return 无
 */
+ (void)request:(NSString * _Nonnull)url
         method:(NSString * _Nonnull)method
     parameters:(NSDictionary * _Nullable)parameters
      timestamp:(NSString * _Nullable)timestamp
    cachePolicy:(cachePolicy)policy
       progress:(progress _Nullable)progress
     completion:(completion _Nullable)completion {

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    //url编码，处理请求中含有中文字符
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    //请求数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"text/plain",
                                                         @"application/xml",
                                                         @"text/xml", nil];
    
    id __progress = ^(NSProgress * _Nonnull _progress) {
        
        float _progress_ = (_progress.completedUnitCount * 100 / _progress.totalUnitCount);
        //NSLog(@"请求进度 : %0.00f%%", _progress_);
        
        if(progress) {progress(_progress_);}
    };
    
    id __success = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"请求成功 : %@ --> %ld", task.response.URL.absoluteString, ((NSHTTPURLResponse *)task.response).statusCode);
        
        //判断MIME类型为json数据
        if([[NSSet setWithObjects:@"application/json",
             @"text/json",
             @"text/javascript",
             @"text/html",
             @"text/plain", nil]
            containsObject:(NSHTTPURLResponse *)task.response.MIMEType]) {
            
            NSError *error = nil;
            AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer new];
            responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"text/plain",nil];
            responseObject = [responseSerializer responseObjectForResponse:task.response
                                                                      data:responseObject
                                                                     error:&error];
            if(responseObject) {
                
                if(completion) {completion(YES, responseObject, nil);}
                if(policy == cachePolicyYes) {
                    [StroageService setValue:responseObject forKey:task.currentRequest.URL.absoluteString serviceType:serviceTypeDefault];
                }
            }
            else {
                
                if(completion) {completion(NO, nil, error);}
            }
        }
        //MIME类型为xml数据，XML->NSDictionary输出
        else if ([[NSSet setWithObjects:@"application/xml",
                   @"text/xml", nil]
                  containsObject:(NSHTTPURLResponse *)task.response.MIMEType]) {
            
            XMLParser *parser = [[XMLParser alloc] init];
            [parser parseData:responseObject
                      success:^(id parsedData) {
                          
                          if(completion) {completion(YES, parsedData, nil);}
                          if(policy == cachePolicyYes) {
                              [StroageService setValue:responseObject forKey:task.currentRequest.URL.absoluteString serviceType:serviceTypeDefault];
                          }
                      }
                      failure:^(NSError *error) {
                          
                          if(completion) {completion(NO, nil, error);}
                      }];
        }
        //其余的MIME类型，NSData->NSString->NSDictionary输出
        else {
            
            responseObject = @{@"response" : [NSString stringFromUTF8Data:responseObject]};
            if(completion) {completion(YES, responseObject, nil);}
            if(policy == cachePolicyYes) {
                [StroageService setValue:responseObject forKey:task.currentRequest.URL.absoluteString serviceType:serviceTypeDefault];
            }
        }
        
        if(timestamp != nil) {[self isUpdate:timestamp uri:url isWritten:YES];}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    id __failure = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"请求失败 : %@ --> %@", (task.response.URL.absoluteString ? : url), error.localizedDescription);
        
        if(completion) {completion(NO, nil, error);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    if([method.uppercaseString isEqualToString:@"GET"]) {
        
         //Creates and runs an `NSURLSessionDataTask` with a `GET` request.
        [manager GET:url
          parameters:parameters
            progress:__progress
             success:__success
             failure:__failure];
    }
    else if([method.uppercaseString isEqualToString:@"POST"]) {
        
         //Creates and runs an `NSURLSessionDataTask` with a `POST` request.
        [manager POST:url
           parameters:parameters
             progress:__progress
              success:__success
              failure:__failure];
    }
}

/**
 * 判断时间戳时候发生变化，若发生变化则存储最近的时间戳
 * @param timestamp : 更新时间戳
 * @param uri : uri
 * @param isWritten :
 * @return BOOL : 是否已更新时间戳
 */
+ (BOOL)isUpdate:(NSString *)timestamp uri:(NSString *)uri isWritten:(BOOL)isWritten {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *timestampValue = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:URITimestamp]];
    
    //时间戳键值都不存在时，创建该uri键值的数据词典并存入到NSUserDefaults中。
    if(timestampValue == nil) {
        if(isWritten) {
            timestampValue = [NSMutableDictionary dictionaryWithObjectsAndKeys:timestamp, uri, nil];
            [userDefaults setObject:timestampValue forKey:URITimestamp];
            [userDefaults synchronize];
        }
        return YES; //时间戳不存在时，需更新获取数据
    }
    else {
        NSString *timestamp_old = [timestampValue valueForKey:uri];
        
        //对应的uri的时间戳存在时，且时间戳数值不相等时，存入当前时间戳并返回YES。
        if(timestamp_old == nil || ([timestamp doubleValue] != [timestamp_old doubleValue] )) {
            if(isWritten) {
                [timestampValue setObject:timestamp forKey:uri];
                [userDefaults setObject:timestampValue forKey:URITimestamp];
                [userDefaults synchronize];
            }
            return YES;
        }
    }
    return NO; //时间戳值相等
}

#pragma mark - 本地文件

/**
 * 判断是否本地文件请求
 * @param url : 文件地址
 * @return BOOL: 是否本地文件
 */
+ (BOOL)isLocalFileRequest:(NSString * _Nonnull)url {

    return [url rangeOfString:@"file://"].location != NSNotFound;
}

/**
 * 请求本地文件
 * @param url : 文件地址
 * @param completion : 回调函数
 * @return 无
 */
+ (void)requestLocalFile:(NSString * _Nonnull)url
              completion:(completion _Nullable)completion {

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    NSRange range = [url rangeOfString:@"file://"];
    NSString *filename = [url substringFromIndex:range.location + range.length];
    NSString *path = [[NSBundle mainBundle] pathForResource:filename.stringByDeletingPathExtension ofType:filename.pathExtension];
    if (!path) {
        NSError *error = [NSError errorWithDomain:NSGlobalDomain
                                             code:-101
                                         userInfo:@{NSLocalizedDescriptionKey : @"文件不存在"}];;
        if(completion) {completion(NO, nil, error);}
    }
    else if([NSData dataWithContentsOfFile:path] == nil
            || [NSData dataWithContentsOfFile:path].length == 0) {
    
        NSError *error = [NSError errorWithDomain:NSGlobalDomain
                                             code:-101
                                         userInfo:@{NSLocalizedDescriptionKey : @"文件内容为空"}];
        if(completion) {completion(NO, nil, error);}
    }
    else if([@"plist" isEqualToString:filename.pathExtension ]) {
        
        id responseJSON = [NSArray arrayWithContentsOfFile:path];
        if(!responseJSON) responseJSON = [NSDictionary dictionaryWithContentsOfFile:path];
        
        if(responseJSON) {
            if(completion) {completion(YES, responseJSON, nil);}
        }
        else {
            NSError *error = [NSError errorWithDomain:NSGlobalDomain
                                                 code:-101
                                             userInfo:@{NSLocalizedDescriptionKey : @"文件解析错误"}];
            if(completion) {completion(NO, nil, error);}
        }
    }
    else if([@"json" isEqualToString:filename.pathExtension ]) {
        
        NSError *error = nil;
        id responseJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
        if(responseJSON) {
            if(completion) {completion(YES, responseJSON, nil);}
        }
        else {
            NSError *error = [NSError errorWithDomain:NSGlobalDomain
                                                 code:-101
                                             userInfo:@{NSLocalizedDescriptionKey : @"文件解析错误"}];
            if(completion) {completion(NO, nil, error);}
        }
    }
    else if([@"xml" isEqualToString:filename.pathExtension]) {
        
        XMLParser *parser = [[XMLParser alloc] init];
        [parser parseData:[NSData dataWithContentsOfFile:path]
                  success:^(id parsedData) {
                      if(completion) {completion(YES, parsedData, nil);}
                  }
                  failure:^(NSError *error) {
                      if(completion) {completion(NO, nil, error);}
                  }];
    }
    else  {
        
        if(completion) {completion(YES, @{@"response" : [NSString stringFromUTF8Data:[NSData dataWithContentsOfFile:path] ]}, nil);}
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

#pragma mark - SOAP

+ (void)soapRequest:(NSString * _Nonnull)url
         completion:(completion _Nullable)completion {
    
    [self soapRequest:url
                     method:nil
                 parameters:nil
                completion:completion];
}

+ (void)soapRequest:(NSString * _Nonnull)url
             method:(NSString * _Nullable)method
         parameters:(NSDictionary * _Nullable)parameters
         completion:(completion _Nullable)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    //url编码，处理请求中含有中文字符
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    //请求数据
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];

    //添加请求报文头信息
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    //创建soap信息
    NSMutableString *soap = [NSMutableString stringWithCapacity:0];
    [soap appendFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                     "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                     "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                     "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                     "<soap:Body>"];
    [soap appendFormat:@"<%@ xmlns=\"http://tempuri.org/\">", method];
    for(NSString *key in parameters) {[soap appendFormat:@"<%@>%@</%@>", key, parameters[key], key];}
    [soap appendFormat:@"</%@>", method];
    [soap appendFormat:@"</soap:Body></soap:Envelope>"];
    [request setHTTPBody:[soap dataUsingEncoding:NSUTF8StringEncoding] ];
    
    //请求回调
    id completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(((NSHTTPURLResponse *)response).statusCode >= 200 && ((NSHTTPURLResponse *)response).statusCode <= 300) {
            
            NSLog(@"请求成功 : %@ --> %ld", response.URL.absoluteString, ((NSHTTPURLResponse *)response).statusCode);
            XMLParser *parser = [[XMLParser alloc] init];
            [parser parseData:data
                      success:^(id parsedData) {
                          
                          NSLog(@"SOAP返回数据 : %@", [NSString stringFromUTF8Data:parsedData]);
                          id envelope = [parsedData valueForKey:@"soap:Envelope"];
                          id body = [envelope valueForKey:@"soap:Body"];
                          id namespace = [body valueForKey:[NSString stringWithFormat:@"ns1:%@Response", method] ];
                          id content = [namespace valueForKeyPath:@"return.content"];
                          if([content isKindOfClass:[NSString class]]) {
                              NSError *error = nil;
                              content = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:NSJSONReadingMutableContainers error:&error];
                              if(error != nil) {
                                  NSLog(@"JSONSerialization failed, error : %@", error);
                                  if(completion) {completion(NO, nil, error);}
                              }
                              else {
                                  if(completion) {completion(YES, content, nil);}
                              }
                          }
                          
                      } failure:^(NSError *error) {
                          
                          if(completion) {completion(NO, nil, error);}
                      }];
        }
        else {
            NSLog(@"请求失败 : %@ --> %@", (response.URL.absoluteString ? : url), error.localizedDescription);
            if(completion) {completion(NO, nil, error);}
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    //发起请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

#pragma mark - HTTP

+ (void)httpRequest:(NSString * _Nonnull)url
         completion:(completion _Nullable)completion {
    
    [self httpRequest:url method:@"GET" parameters:nil completion:completion];
}

+ (void)httpRequest:(NSString * _Nonnull)url
             method:(NSString * _Nullable)method
         parameters:(NSDictionary * _Nullable)parameters
         completion:(completion _Nullable)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    //url编码，处理请求中含有中文字符
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    //请求数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"text/plain",
                                                         @"application/xml",
                                                         @"text/xml", nil];
    
    id __progress = ^(NSProgress * _Nonnull _progress) {
        
        //float _progress_ = (_progress.completedUnitCount * 100 / _progress.totalUnitCount);
        //NSLog(@"请求进度 : %0.00f%%", _progress_);
    };
    
    id __success = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"请求成功 : %@ --> %ld", task.response.URL.absoluteString, ((NSHTTPURLResponse *)task.response).statusCode);
        
        if(completion) {completion(YES, responseObject, nil);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    id __failure = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"请求失败 : %@ --> %@", (task.response.URL.absoluteString ? : url), error.localizedDescription);
        
        if(completion) {completion(YES, nil, error);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    if([method.uppercaseString isEqualToString:@"GET"]) {
        
        //Creates and runs an `NSURLSessionDataTask` with a `GET` request.
        [manager GET:url
          parameters:parameters
            progress:__progress
             success:__success
             failure:__failure];
    }
    else if([method.uppercaseString isEqualToString:@"POST"]) {
        
        //Creates and runs an `NSURLSessionDataTask` with a `POST` request.
        [manager POST:url
           parameters:parameters
             progress:__progress
              success:__success
              failure:__failure];
    }
}

#pragma mark - 上传下载

+ (NSURLSessionDataTask * _Nonnull)uploadFiles:(NSString * _Nonnull)url
                                         files:(NSArray * _Nonnull)files
                                    parameters:(NSDictionary * _Nonnull)parameters
                                      progress:(progress _Nullable)progress
                                       completion:(completion _Nullable)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    //url编码，处理请求中含有中文字符
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    //请求数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"text/plain", nil];
    
    id constructingBodyBlock = ^(id<AFMultipartFormData> _Nonnull formData){
        
        for(NSDictionary *dict in files) {
            [formData appendPartWithFileData:dict[@"filedata"]
                                        name:dict[@"name"]
                                    fileName:dict[@"filename"]
                                    mimeType:dict[@"mimeType"]];
        }
    };
    
    id __progress = ^(NSProgress * _Nonnull _progress) {
        
        float _progress_ = (_progress.completedUnitCount * 100 / _progress.totalUnitCount);
        NSLog(@"上传进度 : %0.00f%%", _progress_);
        
        if(progress) {progress(_progress_);}
    };
    
    id __success = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"上传成功 : %@ --> %ld", task.response.URL.absoluteString, ((NSHTTPURLResponse *)task.response).statusCode);
        
        if(completion) {completion(YES, responseObject, nil);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    id __failure = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传失败 : %@ --> %@", (task.response.URL.absoluteString ? : url), error.localizedDescription);
        
        if(completion) {completion(NO, nil, error);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    //Creates and runs an `NSURLSessionDataTask` with a multipart `POST` request.
    return [manager POST:url
               parameters:parameters
        constructingBodyWithBlock:constructingBodyBlock
                 progress:__progress
                  success:__success
                  failure:__failure];
}

+ (NSURLSessionDataTask * _Nonnull)downloadFile:(NSString * _Nonnull)url
                                     targetPath:(NSString * _Nonnull)targetPath
                                     parameters:(NSDictionary * _Nullable)parameters
                                       progress:(progress _Nullable)progress
                                     completion:(completion _Nullable)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    //url编码，处理请求中含有中文字符
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //请求数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    id __progress = ^(NSProgress * _Nonnull _progress) {
        
        float _progress_ = (_progress.completedUnitCount * 100 / _progress.totalUnitCount);
        NSLog(@"下载进度 : %0.00f%%", _progress_);
        
        if(progress) {progress(_progress_);}
    };
    
    id __success = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"下载成功 : %@ --> %ld", task.response.URL.absoluteString, ((NSHTTPURLResponse *)task.response).statusCode);
        
        if(completion) {completion(YES, responseObject, nil);}
        [responseObject writeToFile:targetPath options:NSDataWritingAtomic error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    id __failure = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"下载失败 : %@ --> %@", (task.response.URL.absoluteString ? : url), error.localizedDescription);
        
        if(completion) {completion(YES, nil, error);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    };
    
    //Creates and runs an `NSURLSessionDataTask` with a `GET` request.
    return [manager GET:url
              parameters:parameters
                progress:__progress
                 success:__success
                 failure:__failure];
}

@end
