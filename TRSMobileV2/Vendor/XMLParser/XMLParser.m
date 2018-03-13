//
//  XMLParser.m
//  XMLParser
//
//  Created by Zouhair on 10/05/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "XMLParser.h"
#import "Stack.h"

#pragma mark - Utilities
BOOL NSStringEqualsXMLNullString(NSString *string);

#pragma mark - Interface
@interface XMLParser () <NSXMLParserDelegate>

#pragma mark Properties
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) id parsedData;
@property (nonatomic, retain) id currentNode;
@property (nonatomic, retain) Stack *parentNodesStack;

@property (nonatomic, retain) NSMutableString *foundCharacters;
@property (nonatomic, retain) NSMutableData *foundCDATA;

@property (nonatomic, copy) void (^success)(id parsedData);
@property (nonatomic, copy) void (^failure)(NSError *error);

@end

#pragma mark - Implementation
@implementation XMLParser

#pragma mark Properties
- (void)setParser:(NSXMLParser *)parser {
	if (![_parser isEqual:parser]) {
		if (_parser) {
			[self.parser abortParsing];
			[self setSuccess:nil];
			[self setFailure:nil];
			[self setParsedData:nil];
		}
		_parser = parser;
	}
}

- (NSMutableString *)foundCharacters {
	if (!_foundCharacters) {
		_foundCharacters = [[NSMutableString alloc] init];
	}
	return _foundCharacters;
}

- (NSMutableData *)foundCDATA {
	if (!_foundCDATA) {
		_foundCDATA = [[NSMutableData alloc] init];
	}
	return _foundCDATA;
}

#pragma mark Parsing Methods
- (void)parseData:(NSData *)data success:(void (^)(id parsedData))success failure:(void (^)(NSError *error))failure {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		self.parser = [[NSXMLParser alloc] initWithData:data];
		
		[self setSuccess:success];
		[self setFailure:failure];
		
		[self startParser];
	});
}

- (void)parseContentsOfURL:(NSURL *)url success:(void (^)(id parsedData))success failure:(void (^)(NSError *error))failure {
	self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	[self setSuccess:success];
	[self setFailure:failure];
	
	[self startParser];
}

- (void)startParser {
	[self.parser setDelegate:self];
	[self.parser parse];
}

#pragma mark - NSXMLParserDelegate
#pragma mark General Document Parsing
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.success(self.parsedData);
	});
}

#pragma mark Errors Reporting
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.failure(parseError);
	});
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.failure(validError);
	});
}

#pragma mark Elements Parsing
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if (!self.parsedData) {
		self.parsedData = [NSMutableDictionary dictionary];
		self.currentNode = self.parsedData;
		self.parentNodesStack = [Stack stack];
	}
	NSString *currentNodeKey = nil;
	if ([self.currentNode objectForKey:elementName]) {
		NSMutableArray *elementsArray = [NSMutableArray arrayWithObjects:[self.currentNode objectForKey:elementName], [XMLParser cleanedAttributes:attributeDict], nil];
		currentNodeKey = [elementName stringByAppendingString:@"sArray"];
		[self.currentNode setObject:elementsArray forKey:currentNodeKey];
		[self.currentNode removeObjectForKey:elementName];
	}
	else if ([self.currentNode objectForKey:[elementName stringByAppendingString:@"sArray"]]) {
		NSMutableArray *currentNode = [self.currentNode objectForKey:[elementName stringByAppendingString:@"sArray"]];
		[currentNode addObject:[XMLParser cleanedAttributes:attributeDict]];
		currentNodeKey = [elementName stringByAppendingString:@"sArray"];
	}
	else {
		currentNodeKey = elementName;
		[self.currentNode setObject:[XMLParser cleanedAttributes:attributeDict] forKey:currentNodeKey];
	}
	[self.parentNodesStack push:self.currentNode];
	id currentNode = [self.currentNode objectForKey:currentNodeKey];
	if ([currentNode isKindOfClass:[NSDictionary class]]) {
		self.currentNode = currentNode;
	}
	else {
		[self.parentNodesStack push:currentNode];
		self.currentNode = [currentNode lastObject];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([self.foundCharacters length] > 0 && !NSStringEqualsXMLNullString(self.foundCharacters)) {
		[self.currentNode setObject:[self.foundCharacters stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"content"];
		[self setFoundCharacters:nil];
	}
	else if ([self.foundCDATA length] > 0 && !NSStringEqualsXMLNullString(self.foundCharacters)) {
		NSString *foundCDATA = [[NSString alloc] initWithData:self.foundCDATA encoding:NSUTF8StringEncoding];
		[self.currentNode setObject:[foundCDATA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"content"];
		[self setFoundCDATA:nil];
	}
	id parentNode = [self.parentNodesStack pop];
	if ([parentNode isKindOfClass:[NSDictionary class]]) {
		self.currentNode = parentNode;
	}
	else {
		self.currentNode = [self.parentNodesStack pop];
	}
}

#pragma mark Datas Parsing
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.foundCharacters appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	
}

#pragma mark Attributes Cleaning
+ (NSMutableDictionary *)cleanedAttributes:(NSDictionary *)attributes {
	NSMutableDictionary *cleanedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
	
	NSSet *nullObjectsKeys = [cleanedAttributes keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
		return ([obj isKindOfClass:[NSString class]] && NSStringEqualsXMLNullString(obj));
	}];
	
	[cleanedAttributes removeObjectsForKeys:[nullObjectsKeys allObjects]];
	
	
	return cleanedAttributes;
}

@end

#pragma mark - Utilities
BOOL NSStringEqualsXMLNullString(NSString *string) {
	return [string isEqualToString:@"null"];
}
