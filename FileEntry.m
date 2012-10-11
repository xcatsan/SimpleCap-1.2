//
//  FileEntry.m
//  SimpleCap
//
//  Created by - on 09/01/18.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "FileEntry.h"

@implementation FileEntry
@synthesize name = _name;
@synthesize created = _created;

- (id)initWithFilename:(NSString*)filename fileAttributes:(NSDictionary*)attrs
{
	self = [super init];
	if (self) {
		_name = [filename retain];
		_created = [[attrs objectForKey:NSFileCreationDate] retain];
	}
	return self;
}

- (void) dealloc
{
	[_name release];
	[_created release];
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ %@", _name, _created];
}

- (NSComparisonResult)compare:(FileEntry*)entry
{
	if ([entry.created isEqualToDate:_created]) {
		if ([[entry.name stringByDeletingPathExtension] hasSuffix:@")"]) {
			return NSOrderedAscending;
		} else {
			return NSOrderedDescending;
		}
	} else {
		return [_created compare:entry.created];	// ASC
	}
//	return [entry.created compare:_created];	// DESC
}
@end
