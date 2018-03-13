//
//  NSString+Extension.m
//  TRSMobileV2
//
//  Created by  TRS on 16/3/15.
//  Copyright © 2016年  TRS. All rights reserved.
//

#import "NSString+Extension.h"
#import "NSDate+Extension.h"
#import "NSArray+Extension.h"
#import "GTMBase64.h"
#import "TFHpple.h"

@implementation NSString (Extension)

+ (NSString * _Nullable)stringFromUTF8Data:(NSData * _Nonnull)data {

    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [str stringByRemovingPercentEncoding];
}

+ (NSString * _Nullable)stringFromCFEncodingData:(NSData * _Nonnull)data encoding:(CFStringEncodings)encoding {
    
    NSStringEncoding s_encoding = CFStringConvertEncodingToNSStringEncoding(encoding);
    return [[NSString alloc] initWithData:data encoding:s_encoding];
}

+ (NSString * _Nonnull)stringFormatValue:(id _Nonnull)object {

    NSString *str = @"";
    if(object == nil || [object isKindOfClass:[NSNull class]]) {
        
    }
    else if([object isKindOfClass:[NSNumber class]]) {
        str = [(NSNumber *)object stringValue];
    }
    else if([object isKindOfClass:[NSString class]] && [(NSString *)object length] && ![object isEqualToString:@"null"]) {
        str = object;
    }
    return str;
}

+ (NSString * _Nonnull)fileSizeForBytes:(long long)bytes {

    if(bytes >= (1024.0*1024.0*1024.0) ) { //大于1G，则转化成G单位的字符串
        
        return [NSString stringWithFormat:@"%.2fGB",bytes/(1024.0*1024.0*1024.0) ];
    }
    else if(bytes >= (1024.0*1024.0) ) { //大于1M，则转化成M单位的字符串
        
        return [NSString stringWithFormat:@"%.2fMB",bytes/(1024.0*1024.0) ];
    }
    else if(bytes >= 1024.0) { //不到1M,但是超过了1KB，则转化成KB单位
        
        return [NSString stringWithFormat:@"%.2fKB",bytes/1024.0];
    }
    else { //剩下的都是小于1K的，则转化成B单位
        
        return [NSString stringWithFormat:@"%.2fBytes", (float)bytes];
    }
}

+ (NSInteger)stringLength:(NSString * _Nonnull)string {

    NSInteger len = 0;
    char* p = (char*) [string cStringUsingEncoding:NSUnicodeStringEncoding];
    for (NSUInteger i = 0 ; i < [string lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            len++;
        }
        else {
            p++;
        }
    }
    return len;
}

+ (NSString * _Nonnull)mobilePhoneFilter:(NSString * _Nonnull)mobile {

    if(mobile == nil || [mobile length] == 0) {return @"";}
    
    NSMutableString *phone = [NSMutableString stringWithCapacity:0];
    for(NSUInteger i = 0; i < [mobile length]; i++) {
        char ch = [mobile characterAtIndex:i];
        if(ch >= '0' && ch <= '9') {
            [phone appendFormat:@"%c", ch];
        }
    }
    
    return phone;
}

+ (BOOL)isValidMobilePhone:(NSString * _Nonnull)mobile {

    NSString *mobileRegex = @"1\\d{10}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    
    return [predicate evaluateWithObject:mobile];
}

+ (NSString * _Nonnull)getTowerWithMonth:(NSInteger)month day:(NSInteger)day {

    static NSString *tower_d = @"魔羯座";
    NSString *towerString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *towerFormat = @"102123444543";
    NSString *result = nil;
    
    if (month < 1
        || month > 12
        || day < 1
        || day > 31){
        return tower_d;
    }
    
    if( month == 2
       && day > 29) {
        return tower_d;
    }
    else if(month == 4
            || month == 6
            || month == 9
            || month == 11) {
        if (day > 30) {
            return tower_d;
        }
    }
    result = [NSString stringWithFormat:@"%@座", [towerString substringWithRange:NSMakeRange(month*2-(day < [[towerFormat substringWithRange:NSMakeRange((month-1), 1)] intValue] - (-19))*2,2)]];
    
    return result;
}

+ (NSString * _Nonnull)ageValue:(NSString * _Nonnull)year month:(NSString * _Nonnull)month day:(NSString * _Nonnull)day {

    NSArray *array = [[[NSString stringWithFormat:@"%@", [NSDate date]] substringToIndex:10] componentsSeparatedByString:@"-"];
    int _year = [[array objectAtIndex:0] intValue] - [[self stringFormatValue:year] intValue];
    int _month= [[array objectAtIndex:1] intValue] - [[self stringFormatValue:month] intValue];
    int _day  = [[array objectAtIndex:2] intValue] - [[self stringFormatValue:day] intValue];
    
    if(_month < 0) { //当前月份为出生月份之前
        --_year;
    }
    else if(_month == 0 && _day <0) { //同月，但当前日期在出生日期之前
        --_year;
    }
    
    return [NSString stringWithFormat:@"%d", _year];
}

+ (NSString * _Nonnull)distanceValue:(NSString * _Nonnull)distance {

    float _distance = [[self stringFormatValue:distance] floatValue];
    if(_distance >= 1000) {
        
        return [NSString stringWithFormat:@"%0.2fkm",   _distance/1000];
    }
    else if(_distance >= 100) {
        
        return [NSString stringWithFormat:@"%0.0fm",   _distance];
    }
    else {
        
        return [NSString stringWithFormat:@"<100m"];
    }
}

+ (NSString * _Nonnull)getWeekByWeekday:(int)weekday {
    
    if(weekday < 1 || weekday > 7) return @"未知";
    return @[@"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"][(weekday - 1)];
}

+ (NSInteger)weekDay {
    
    NSDateComponents *components =  [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:[NSDate date]];
    NSInteger weekday = components.weekday;
    
    if(weekday == 1)
        return 7;
    return weekday - 1;
}

+ (NSString * _Nonnull)videoPlayTimeValue:(double)time {

    NSString *result = @"";
    int hour = 0, min = 0, sec = 0;
    if(time > 60*60) {
        hour = time / (60 * 60);
        time -= hour * (60 * 60);
    }
    if(time > 60) {
        min = time / 60;
        time -= min * 60;
    }
    sec = time;
    
    if(hour > 0)
        result = [NSString stringWithFormat:@"%0.2d:%0.2d:%0.2d", hour, min, sec];
    else
        result = [NSString stringWithFormat:@"%0.2d:%0.2d", min, sec];
    
    return result;
}

+ (NSString * _Nonnull)timeValue:(NSString * _Nonnull)dateString {

    NSDate *date = [NSDate dateByDateString:dateString format:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeInterval timeInteval = -[date timeIntervalSinceNow]; //距离当前时间的时间戳取反，得到正的时间秒数
    
    NSString *value = nil; int temp = 0;
    if(timeInteval < 60) { //60秒以内
        value = @"刚刚";
    }
    else if((temp = timeInteval/60) < 60 ) { //1小时以内
        value = [NSString stringWithFormat:@"%d分钟前", temp];
    }
    else if((temp = temp/60) < 24) { //超过1小时今天以内
        value = [NSString stringWithFormat:@"%d小时前", temp];
    }
    else if((temp = temp/24) < 1) { //今天
        value = @"今天";
    }
    else if((temp) < 2) { //昨天
        value = @"昨天";
    }
    else {
        //判断是当年还是往年
        BOOL isYearSame = ([NSDate getYear:date] == [NSDate getYear:[NSDate date] ]);
        NSString *format = isYearSame ? @"MM-dd HH:mm" : @"YYYY-MM-dd HH:mm";
        value = [NSDate dateStringByDate:date format:format];
    }
    
    return value;
}

+ (void)getImagesFromWebView:(WKWebView * _Nonnull)webView completion:(void (^ _Nullable)(NSArray * _Nonnull imageUrls))completion {

    //整个网页的html页面内容
    [webView evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:0];
        
        //当前网页请求的上级地址
        NSString *rootUrl = [[webView.URL.absoluteString stringByDeletingLastPathComponent]
                             stringByReplacingOccurrencesOfString:@":/" withString:@"://"];
        
        //在页面中查找img标签
        TFHpple *doc = [TFHpple hppleWithData:[response dataUsingEncoding:NSUTF8StringEncoding] isXML:YES];
        NSArray *images = [doc searchWithXPathQuery:@"//img"];
        for(NSUInteger i = 0; i < images.count; i++) {
            
            NSString *imageUrl = [images[i] objectForKey:@"src"];
            
            //兼容性检查
            if(imageUrl == nil || imageUrl.length == 0) {continue;}
            
            //过滤图片
            if(![NSString isValidImageUrl:imageUrl]) {continue;}
            
            //判断相对路径还是绝对路径，如果是以http开头，则是绝对地址，否则是相对地址
            if(NSNotFound != [imageUrl rangeOfString:@"http"].location
               && ![imageUrls containsObject:imageUrl]) {
                [imageUrls addObject:imageUrl];
            }
            else {
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"../" withString:@""];
                imageUrl = [rootUrl  stringByAppendingFormat:@"/%@", imageUrl.stringByStandardizingPath];
                if(![imageUrls containsObject:imageUrl]) [imageUrls addObject:imageUrl];
            }
        }
        
        if(completion) {completion(imageUrls);}
    }];
}

+ (BOOL)isValidImageUrl:(NSString * _Nonnull)url {

    BOOL isValid = YES;
    for(NSString *str in valueForArrayFile(@"imageFliter")) {
        if([url hasSubString:str]) {
            isValid = NO;
            break;
        }
    }
    return isValid;
}

+ (NSString * _Nullable)fliterHTML:(NSString * _Nullable)str {
    
    NSScanner * scanner = [NSScanner scannerWithString:str];
    NSString * text = nil;
    while([scanner isAtEnd] == NO) {
        
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        
        //替换字符
        str = [str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    
    return str;
}

- (BOOL)hasSubString:(NSString * _Nonnull)substr {
    
    return [self rangeOfString:substr].location != NSNotFound;
}

- (CGSize)sizeWithFont:(UIFont * _Nonnull)font maxSize:(CGSize)maxSize {

    return [self boundingRectWithSize:maxSize
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName : font}
                              context:nil].size;
}

@end


@implementation NSString (Util)

+ (NSString * _Nonnull)sha1:(NSString * _Nonnull)str {
    
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString * _Nonnull)md5:(NSString * _Nonnull)str {

    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result );
    NSString *output = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return output;
}

+ (NSString * _Nullable)des:(NSString * _Nonnull)str key:(NSString * _Nonnull)key isEncrypt:(BOOL)isEncrypt {

    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt((isEncrypt ? kCCEncrypt : kCCDecrypt),
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    
    NSString* output = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *__temp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        output = [[NSString alloc] initWithData:__temp encoding:NSUTF8StringEncoding];
    }
    
    return output;
}

@end


@implementation NSString (IDS)

+ (NSString * _Nullable)IDSEncrypt:(NSString * _Nonnull)str key:(NSString * _Nonnull)key {
    
    //加密方式：字符串先做Base64编码->DES加密->NSData转换为16进制字符串
    NSData *data = [GTMBase64 encodeData:[str dataUsingEncoding:NSUTF8StringEncoding] ];
    
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          key.UTF8String,
                                          kCCKeySizeDES,
                                          NULL,
                                          data.bytes,
                                          data.length,
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    
    NSString* output = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *__temp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        output = [NSString convertDataToHexStr:__temp];
    }
    
    return output;
}

+ (NSString * _Nullable)IDSDecrypt:(NSString * _Nonnull)str key:(NSString * _Nonnull)key {
    
    //解密方式：字符串转换成16进制字节数据->DES解密->字节数组转换成16进制字符串->Base64解码->字节数组采用utf8格式输出字符串
    NSData *data = [NSString convertHexStrToData:str];
    
    unsigned char buffer[1024 * 8];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          key.UTF8String,
                                          kCCKeySizeDES,
                                          NULL,
                                          data.bytes,
                                          data.length,
                                          buffer,
                                          1024 * 8,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        
        //获取的byte数组
        NSData *__temp = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        
        //将byte数组转成16进制数组
        NSString *__str = [NSString convertDataToHexStr:__temp];
        
        //将16进制数组转成byte数组
        NSData *__data = [NSString convertHexStrToData:__str];
        
        //对转成16进制的byte数组进行base64解码
        NSData *__data2 = [GTMBase64 decodeData:__data];
        
        //将解码后的byte数组转成字符串
        plainText = [[NSString alloc] initWithData:__data2 encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

+ (NSData * _Nonnull)convertHexStrToData:(NSString * _Nonnull)str {
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

+ (NSString * _Nonnull)convertDataToHexStr:(NSData * _Nonnull)data {
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

@end
