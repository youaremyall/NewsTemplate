//
//  Stack.h
//  XMLParser
//
//  Created by Zouhair on 10/05/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject

/** @name Static Initializer */
#pragma mark Static Initializer
+ (id)stack;

/** @name Access methods */
#pragma mark Access methods
- (void)push:(id)object;
- (id)pop;

@end
