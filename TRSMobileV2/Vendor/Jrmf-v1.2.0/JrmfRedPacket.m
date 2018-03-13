//
//  JrmfRedPacket.m
//  TRSMobileV2
//
//  Created by  TRS on 2017/1/19.
//  Copyright © 2017年  TRS. All rights reserved.
//

#import "JrmfRedPacket.h"
#import "AFHTTP+Provider.h"
#import "NSDate+Extension.h"
#import "NSString+Extension.h"

@implementation JrmfRedPacket

+ (void)getWebToken:(NSString* _Nonnull)custUid nickName:(NSString* _Nullable)nickName avatar:(NSString* _Nullable)avatar completion:(completionBlock _Nullable)completion {

    //加密部分
    NSMutableDictionary *signParam = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *timestamp = [NSDate dateStringByDate:[NSDate date] format:@"yyyyMMddHHmmss"];
    [signParam addEntriesFromDictionary:@{@"custUid" : custUid,
                                          @"partnerId" : kPartnerID,
                                          @"timeStamp" : timestamp,
                                          @"seckey" : kPartnerSecKey
                                          }];
    if(nickName) {
        [signParam setObject:nickName forKey:@"nickName"];
    }
    if(avatar) {
        [signParam setObject:[GTMBase64 stringByEncodingData:[avatar dataUsingEncoding:NSUTF8StringEncoding] ] forKey:@"avatar"];
    }
    NSString *sign = [self encodeParamters:signParam];
    
    //请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                      @"custUid"   : custUid,
                                      @"timeStamp" : timestamp,
                                      @"sign"      : sign
                                      }];
    if(avatar) {[param setObject:[GTMBase64 stringByEncodingData:[avatar dataUsingEncoding:NSUTF8StringEncoding] ] forKey:@"avatar"];}
    if(nickName) {[param setObject:nickName forKey:@"nickName"];}
    NSLog(@"获取用户令牌：%@\n红包参数：%@", kGetWebTokenUrl, param);
    
    [AFHTTP request:kGetWebTokenUrl method:@"POST" parameters:param progress:nil completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                       
                       if(success) {
                           NSLog(@"得到用户令牌：%@", response[@"webToken"]);
                           if(completion) {completion(YES, response, nil);}
                       }
                       else {
                           if(completion) {completion(NO, nil, error);}
                       }
                       
                   }];
}

+ (void)getOperateRedEnvelope:(NSString* _Nonnull )redPacket webToken:(NSString* _Nullable)webToken completion:(completionBlock _Nullable)completion {

    //加密部分
    NSString *timestamp = [NSDate dateStringByDate:[NSDate date] format:@"yyyyMMddHHmmss"];
    NSMutableDictionary *signParam = [NSMutableDictionary dictionaryWithCapacity:0];
    [signParam addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                     @"triggerId" : redPacket,
                                     @"uniqueID"  : KEY_IDFV,
                                     @"timeStamp" : timestamp,
                                     @"seckey"    : kPartnerSecKey
                                     }];
    if(webToken) {[signParam setObject:webToken forKey:@"webToken"];}
    NSString *sign = [self encodeParamters:signParam];
    
    //请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                      @"triggerId" : redPacket,
                                      @"timeStamp" : timestamp,
                                      @"uniqueID"  : KEY_IDFV,
                                      @"sign"      : sign
                                      }];
    if(webToken) {[param setObject:webToken forKey:@"webToken"];}
    NSLog(@"发送唯一红包：%@\n红包参数：%@", kOperateRedEnvelopeUrl, param);
    
    [AFHTTP request:kOperateRedEnvelopeUrl method:@"POST" parameters:param progress:nil completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
        
        if(success) {
        
            //解析红包数据
            NSString *respstat = response[@"respstat"];
            if([respstat isEqualToString:kSuccessFlag]) { //成功
                
                NSString *redEnvelopeUrl = response[@"redEnvelopeUrl"];
                
                //请求参数
                NSMutableString *param2 = [NSMutableString stringWithCapacity:0];
                NSString *envelopeId = [response valueForKeyPath:@"requestParams.envelopeId"];
                [param2 appendFormat:@"envelopeId=%@&uniqueID=%@&partnerId=%@", envelopeId, KEY_IDFV, kPartnerID];
                if(webToken) {[param2 appendFormat:@"&webToken=%@", webToken];}
                
                //加密部分
                NSMutableDictionary *signParam2 = [NSMutableDictionary dictionaryWithCapacity:0];
                [signParam2 addEntriesFromDictionary:@{@"envelopeId" : envelopeId,
                                                       @"partnerId"  : kPartnerID,
                                                       @"uniqueID"   : KEY_IDFV,
                                                       @"seckey"     : kPartnerSecKey
                                                       }];
                if(webToken) {[signParam2 setObject:webToken forKey:@"webToken"];}
                NSString *sign2 = [self encodeParamters:signParam2];
                
                //整合红包地址
                NSString *url = [NSString stringWithFormat:@"%@?%@&sign=%@", redEnvelopeUrl, param2, sign2];
                
                NSLog(@"得到唯一红包地址：%@", url);
                if(completion) {completion(YES, @{@"redEnvelopeUrl" : url}, nil);}
            }
            else {
                NSLog(@"发送唯一红包失败：%@", response[@"respmsg"]);
            }
        }
        else {
            
            if(completion) {completion(NO, nil, error);}
        }
    }];
}

+ (void)getCommonRedEnvelope:(NSString* _Nonnull)redPacket webToken:(NSString* _Nullable)webToken completion:(completionBlock _Nullable)completion {

    //加密部分
    NSString *timestamp = [NSDate dateStringByDate:[NSDate date] format:@"yyyyMMddHHmmss"];
    NSMutableDictionary *signParam = [NSMutableDictionary dictionaryWithCapacity:0];
    [signParam addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                          @"triggerId" : redPacket,
                                          @"timeStamp" : timestamp,
                                          @"seckey"    : kPartnerSecKey
                                          }];
    if(webToken) {[signParam setObject:webToken forKey:@"webToken"];}
    NSString *sign = [self encodeParamters:signParam];
    
    //请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                      @"triggerId" : redPacket,
                                      @"timeStamp" : timestamp,
                                      @"sign"      : sign
                                      }];
    if(webToken) {[param setObject:webToken forKey:@"webToken"];}
    NSLog(@"发送普惠红包：%@\n红包参数：%@", kCommonRedEnvelopeUrl, param);
    
    [AFHTTP request:kCommonRedEnvelopeUrl method:@"POST" parameters:param progress:nil completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
        
        if(success) {
        
            //解析红包数据
            NSString *respstat = response[@"respstat"];
            if([respstat isEqualToString:kSuccessFlag]) { //成功
                
                
                NSString *redEnvelopeUrl = response[@"redEnvelopeUrl"];
                
                //请求参数
                NSMutableString *param2 = [NSMutableString stringWithCapacity:0];
                NSString *envelopeId = [response valueForKeyPath:@"requestParams.envelopeId"];
                [param2 appendFormat:@"envelopeId=%@&uniqueID=%@&partnerId=%@", envelopeId, KEY_IDFV, kPartnerID];
                
                //整合红包地址
                NSString *url = [NSString stringWithFormat:@"%@?%@", redEnvelopeUrl, param2];
                if(completion) {completion(YES, @{@"redEnvelopeUrl" : url}, nil);}
                
                NSLog(@"得到普惠红包地址：%@", url);
                if(completion) {completion(YES, @{@"redEnvelopeUrl" : url}, nil);}
                
            }
            else {
                NSLog(@"发送普惠红包失败：%@", response[@"respmsg"]);
            }
        }
        else {
            
            if(completion) {completion(NO, nil, error);}
        }
    }];
}

+ (void)getCardCoupon:(NSString* _Nonnull )redPacket webToken:(NSString* _Nullable)webToken completion:(completionBlock _Nullable)completion {

    //加密部分
    NSString *timestamp = [NSDate dateStringByDate:[NSDate date] format:@"yyyyMMddHHmmss"];
    NSMutableDictionary *signParam = [NSMutableDictionary dictionaryWithCapacity:0];
    [signParam addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                          @"triggerId" : redPacket,
                                          @"uniqueID"  : KEY_IDFV,
                                          @"timeStamp" : timestamp,
                                          @"seckey"    : kPartnerSecKey
                                          }];
    if(webToken) {[signParam setObject:webToken forKey:@"webToken"];}
    NSString *sign = [self encodeParamters:signParam];
    
    //请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param addEntriesFromDictionary:@{@"partnerId" : kPartnerID,
                                      @"triggerId" : redPacket,
                                      @"timeStamp" : timestamp,
                                      @"uniqueID"  : KEY_IDFV,
                                      @"sign"      : sign
                                      }];
    if(webToken) {[param setObject:webToken forKey:@"webToken"];}
    NSLog(@"发送卡券红包：%@\n红包参数：%@", kGetCardCouponUrl, param);
    
    [AFHTTP request:kGetCardCouponUrl method:@"POST" parameters:param progress:nil completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {

        if(success) {
        
            //解析红包数据
            NSString *respstat = response[@"respstat"];
            if([respstat isEqualToString:kSuccessFlag]) { //成功
                
                NSString *redEnvelopeUrl = response[@"redEnvelopeUrl"];
                
                //请求参数
                NSMutableString *param2 = [NSMutableString stringWithCapacity:0];
                NSString *envelopeId = [response valueForKeyPath:@"requestParams.envelopeId"];
                [param2 appendFormat:@"envelopeId=%@&uniqueID=%@&partnerId=%@", envelopeId, KEY_IDFV, kPartnerID];
                if(webToken) {[param2 appendFormat:@"&webToken=%@", webToken];}
                
                //加密部分
                NSMutableDictionary *signParam2 = [NSMutableDictionary dictionaryWithCapacity:0];
                [signParam2 addEntriesFromDictionary:@{@"envelopeId" : envelopeId,
                                                       @"partnerId"  : kPartnerID,
                                                       @"uniqueID"   : KEY_IDFV,
                                                       @"seckey"     : kPartnerSecKey
                                                       }];
                if(webToken) {[signParam2 setObject:webToken forKey:@"webToken"];}
                NSString *sign2 = [self encodeParamters:signParam2];
                
                //整合红包地址
                NSString *url = [NSString stringWithFormat:@"%@?%@&sign=%@", redEnvelopeUrl, param2, sign2];
                
                NSLog(@"卡券普惠红包地址：%@", url);
                if(completion) {completion(YES, @{@"redEnvelopeUrl" : url}, nil);}
            }
            else {
                NSLog(@"发送卡券红包失败：%@", response[@"respmsg"]);
            }
        }
        else {

            if(completion) {completion(NO, nil, error);}
        }
    }];
}

#pragma mark -

/**
 * @brief 对词典参数按照ASCII码递增后排序编码
 */
+ (NSString *)encodeParamters:(NSDictionary *)paramters {

    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    NSInteger i = 0;
    NSArray *allKeys = [paramters.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ([obj2 compare:obj1] == NSOrderedAscending);
    }];
    
    for(NSString *key in allKeys) {
        [str appendFormat:@"%@%@:%@", (i == 0 ? @"" : @"|"), key, paramters[key] ];
        i++;
    }
    NSString *ret = [NSString md5:str];
    
    return ret;
}

@end
