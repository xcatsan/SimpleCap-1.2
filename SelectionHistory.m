//
//  SelectionHistory.m
//  SimpleCap
//
//  Created by - on 08/10/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SelectionHistory.h"
#import "UserDefaults.h"

#define MAX_HISTORY	  10

@implementation SelectionHistory


- (void)load
{
/*	if (_history_list) {
		[_history_list release];
	}
	_history_list = [[NSMutableArray alloc] init];
	NSArray* array = [UserDefaults valueForKey:UDKEY_SELECTION_HISTORY];
	for (NSString* str in array) {
		NSSize size = NSSizeFromString(str);
		[_history_list addObject:[NSValue valueWithSize:size]];
	}*/
}
- (void)save
{
/*	NSMutableArray* array = [NSMutableArray array];
	for (NSValue* value in _history_list) {
		NSString* size = NSStringFromSize([value sizeValue]);
		[array addObject:size];
	}
	[UserDefaults setValue:array forKey:UDKEY_SELECTION_HISTORY];
	[UserDefaults save];*/
}

- (id)init
{
	self = [super init];
	if (self) {
		[self load];
	}
	return self;
}

- (void) dealloc
{
	[_history_list release];
	[super dealloc];
}

- (void)setSize:(NSSize)size
{
	NSValue* value = [NSValue valueWithSize:size];
	[_history_list addObject:value];
	if ([_history_list containsObject:value]) {
		[_history_list removeObject:value];
	}
	if ([_history_list count] == MAX_HISTORY) {
		[_history_list removeObjectAtIndex:(MAX_HISTORY-1)];
	}

	[_history_list insertObject:value atIndex:0];
	[self save];
}

- (NSSize)sizeAtIndex:(int)index
{
	return [[_history_list objectAtIndex:index] sizeValue];
}

- (NSArray*)menuList
{
	NSMutableArray* results = [NSMutableArray array];
	for (NSValue* value in _history_list) {
		NSSize size = [value sizeValue];
		[results addObject:[NSString stringWithFormat:@"%.0f x %.0f", size.width, size.height]];
	}
	return results;
}

+ (SelectionHistory*)selectionHistory
{
	SelectionHistory* history = [[[SelectionHistory alloc] init] autorelease];
	return history;
}

@end
