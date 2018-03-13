//
//  RNCachingURLProtocol.m
//
//  Created by Robert Napier on 1/10/12.
//  Copyright (c) 2012 Rob Napier.
//
//  This code is licensed under the MIT License:
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "RNCachingURLProtocol.h"
#import "AFHTTP+Provider.h"
#import "NSString+Extension.h"

#ifdef SD_WEBP
#import "UIImage+WebP.h"
#endif

#define WORKAROUND_MUTABLE_COPY_LEAK 1

#if WORKAROUND_MUTABLE_COPY_LEAK
// required to workaround http://openradar.appspot.com/11596316
@interface NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround;

@end
#endif

@interface RNCachedData : NSObject <NSCoding>

@property (nonatomic, readwrite, strong) NSData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@property (nonatomic, readwrite, strong) NSURLRequest *redirectRequest;

@end

static NSString *RNCachingURLHeader = @"X-RNCache";

//wujianjun 2015-05-21 add for 处理网页显示webp格式图片
static NSString * const STWebPURLRequestHandledKey = @"stwebp-handled";
static NSString * const STWebPURLRequestHandledValue = @"handled";
//add end.

@interface RNCachingURLProtocol () // <NSURLConnectionDelegate, NSURLConnectionDataDelegate> iOS5-only

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@property (nonatomic, readwrite, assign) BOOL  isWebPPNG;

- (void)appendData:(NSData *)newData;

@end

static NSObject *RNCachingSupportedSchemesMonitor;
static NSSet *RNCachingSupportedSchemes;

@implementation RNCachingURLProtocol
@synthesize connection = connection_;
@synthesize data = data_;
@synthesize response = response_;

+ (void)initialize {
    
    if(self == [RNCachingURLProtocol class]) {
      
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            RNCachingSupportedSchemesMonitor = [NSObject new];
        });
        [self setSupportedSchemes:[NSSet setWithObject:@"http"]];
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
      // only handle http requests we haven't marked with our header.
      if ([[self supportedSchemes] containsObject:[[request URL] scheme]]
          && ([request valueForHTTPHeaderField:RNCachingURLHeader] == nil)) {
          return YES;
      }
      return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    //...若请求地址是含有webp格式的图片，则修改请求请求头，增加Accept字段
    //wujianjun 2015-05-21 add for 处理网页显示webp格式图片
    NSString *url = request.URL.absoluteString.lowercaseString;
    if([url.pathExtension isEqualToString:@"webp"]) {
        NSMutableURLRequest *__request = [NSMutableURLRequest requestWithURL:request.URL
                                                                       cachePolicy:request.cachePolicy
                                                                   timeoutInterval:request.timeoutInterval];
        [__request addValue:@"image/webp" forHTTPHeaderField:@"Accept"];
        [self setProperty:STWebPURLRequestHandledValue forKey:STWebPURLRequestHandledKey inRequest:__request];
        return __request;
    }
    //add end
    
    return request;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest {
    
    NSString *cachesPath = [RNCachingURLProtocol getRNCachingPath];
    NSString *fileName = [NSString sha1:aRequest.URL.absoluteString];
    
    return [cachesPath stringByAppendingPathComponent:fileName];
}

- (void)startLoading {
    
  if (![self useCache]) {
        NSMutableURLRequest *connectionRequest =
        #if WORKAROUND_MUTABLE_COPY_LEAK
              [[self request] mutableCopyWorkaround];
        #else
              [[self request] mutableCopy];
        #endif
            // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
            [connectionRequest setValue:@"" forHTTPHeaderField:RNCachingURLHeader];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:connectionRequest
                                                                        delegate:self];
            [self setConnection:connection];
      }
      else {
            RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
            if (cache) {
                  NSData *data = [cache data];
                  NSURLResponse *response = [cache response];
                  NSURLRequest *redirectRequest = [cache redirectRequest];
                  if (redirectRequest) {
                      [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
                  } else {
                      [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle caching ourselves.
                      [[self client] URLProtocol:self didLoadData:data];
                      [[self client] URLProtocolDidFinishLoading:self];
                  }
            }
            else {
                [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
            }
      }
}

- (void)stopLoading {
    
    [[self connection] cancel];
}

// NSURLConnection delegates (generally we pass these on to our client)
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    
    // Thanks to Nick Dowell https://gist.github.com/1885821
      if (response != nil) {
              NSMutableURLRequest *redirectableRequest =
        #if WORKAROUND_MUTABLE_COPY_LEAK
              [request mutableCopyWorkaround];
        #else
              [request mutableCopy];
        #endif
            // We need to remove our header so we know to handle this request and cache it.
            // There are 3 requests in flight: the outside request, which we handled, the internal request,
            // which we marked with our header, and the redirectableRequest, which we're modifying here.
            // The redirectable request will cause a new outside request from the NSURLProtocolClient, which 
            // must not be marked with our header.
            [redirectableRequest setValue:nil forHTTPHeaderField:RNCachingURLHeader];

            NSString *cachePath = [self cachePathForRequest:[self request]];
            RNCachedData *cache = [RNCachedData new];
            [cache setResponse:response];
            [cache setData:[self data]];
            [cache setRedirectRequest:redirectableRequest];
            [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
            [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
          
            return redirectableRequest;
      }
      else {
          
          return request;
      }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //wujianjun 2015-05-21 delete for 处理网页显示webp格式图片
    //[[self client] URLProtocol:self didLoadData:data];
    //delete end
    [self appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [[self client] URLProtocol:self didFailWithError:error];
    [self setConnection:nil];
    [self setData:nil];
    [self setResponse:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    [self setResponse:response];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];  // We cache ourselves.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //wujianjun 2015-05-21 add for 处理网页显示webp格式图片
    BOOL isWebP = [[connection.currentRequest valueForHTTPHeaderField:@"Accept"] isEqualToString:@"image/webp"];
    if(isWebP) {
        UIImage *image = [UIImage sd_imageWithWebPData:self.data];
        if (!image) {
            [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:nil]];
            return;
        }
        NSData *imagePNGData = UIImagePNGRepresentation(image);
        [[self client] URLProtocol:self didLoadData:imagePNGData];
    }
    //add end.
    else {
        [[self client] URLProtocol:self didLoadData:self.data];
    }
    [[self client] URLProtocolDidFinishLoading:self];

    NSString *cachePath = [self cachePathForRequest:[self request]];
    RNCachedData *cache = [RNCachedData new];
    [cache setResponse:[self response]];
    [cache setData:[self data]];
    [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
    
    [self setConnection:nil];
    [self setData:nil];
    [self setResponse:nil];
}

- (BOOL) useCache  {
    
    /*仅当网络不可用，并且存在缓存数据时，才使用缓存；否则使用网络请求数据*/
    if(statusAFNetworkReachability == AFNetworkReachabilityStatusNotReachable) {
        RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
        if(cache && cache.response) {
            return YES;
        }
    }
    return NO;
}

- (void)appendData:(NSData *)newData {
    
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    }
    else {
        [[self data] appendData:newData];
    }
}

+ (NSSet *)supportedSchemes {
    
    NSSet *supportedSchemes;
    @synchronized(RNCachingSupportedSchemesMonitor){
        
        supportedSchemes = RNCachingSupportedSchemes;
    }
    return supportedSchemes;
}

+ (void)setSupportedSchemes:(NSSet *)supportedSchemes {
    
    @synchronized(RNCachingSupportedSchemesMonitor){
        
        RNCachingSupportedSchemes = supportedSchemes;
    }
}

/**
 * 所有网页缓存的存储目录路径
 */
+ (NSString *)getRNCachingPath {

    // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    /*创建自定义的网页数据缓存目录，避免缓存文件一大堆都放在/Library/Caches/目录下*/
    NSString *__cachesPath = [cachesPath stringByAppendingPathComponent:@"default/com.UIWebViewCache.default"];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:__cachesPath];
    if(!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:__cachesPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return __cachesPath;
}

/**
 * 所有网页缓存的数据文件大小
 */
+ (NSUInteger)getSize {
 
    NSString *cachesPath = [RNCachingURLProtocol getRNCachingPath];
    __block NSUInteger size = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:cachesPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [cachesPath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    
    return size;
}

/**
 * 清空所有网页缓存的数据.
 */
+ (void)clearAllRNCaches {

    NSString *cachesPath = [RNCachingURLProtocol getRNCachingPath];
    [[NSFileManager defaultManager] removeItemAtPath:cachesPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:cachesPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}


@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static NSString *const kRedirectRequestKey = @"redirectRequest";

@implementation RNCachedData
@synthesize data = data_;
@synthesize response = response_;
@synthesize redirectRequest = redirectRequest_;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:[self data] forKey:kDataKey];
    [aCoder encodeObject:[self response] forKey:kResponseKey];
    [aCoder encodeObject:[self redirectRequest] forKey:kRedirectRequestKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self != nil) {
        [self setData:[aDecoder decodeObjectForKey:kDataKey]];
        [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
        [self setRedirectRequest:[aDecoder decodeObjectForKey:kRedirectRequestKey]];
    }

    return self;
}

@end

#if WORKAROUND_MUTABLE_COPY_LEAK
@implementation NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround {
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                          cachePolicy:[self cachePolicy]
                                                                      timeoutInterval:[self timeoutInterval]];
    [mutableURLRequest setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    if ([self HTTPBodyStream]) {
        [mutableURLRequest setHTTPBodyStream:[self HTTPBodyStream]];
    } else {
        [mutableURLRequest setHTTPBody:[self HTTPBody]];
    }
    [mutableURLRequest setHTTPMethod:[self HTTPMethod]];
    
    return mutableURLRequest;
}

@end
#endif
