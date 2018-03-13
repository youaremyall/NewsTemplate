//
//  Stack.m
//  XMLParser
//
//  Created by Zouhair on 10/05/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "Stack.h"

@interface Stack ()

#pragma mark Properties
@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation Stack

#pragma mark Properties
- (NSMutableArray *)items {
	if (!_items) {
		_items = [[NSMutableArray alloc] init];
	}
	return _items;
}

#pragma mark Static Initializer
+ (id)stack {
	return [[Stack alloc] init];
}

#pragma mark Access methods
- (void)push:(id)object {
	if (object) {
		[self.items insertObject:object atIndex:0];
	}
}

- (id)pop {
	id object = nil;
    if ([self.items count] > 0) {
        object = [self.items objectAtIndex:0];
        [self.items removeObjectAtIndex:0];
    }
	return object;
}

#pragma mark Utilities
- (NSString *)description {
	return [self.items description];
}

@end
