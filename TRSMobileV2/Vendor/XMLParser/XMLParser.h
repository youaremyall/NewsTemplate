//
//  XMLParser.h
//  XMLParser
//
//  Created by Zouhair on 10/05/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject

/** @name Parsing Methods */
#pragma mark - Parsing Methods
- (void)parseData:(NSData *)data
          success:(void (^)(id parsedData))success
          failure:(void (^)(NSError *error))failure;

- (void)parseContentsOfURL:(NSURL *)url
                   success:(void (^)(id parsedData))success
                   failure:(void (^)(NSError *error))failure;

@end
