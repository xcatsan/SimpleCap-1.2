//
//  FileList.m
//  SimpleCap
//
//  Created by - on 09/01/18.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "FileList.h"
#import "FileEntry.h"

@implementation FileList

- (id)init
{
	self = [super init];
	if (self) {
		_list = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[_list release];
	[super dealloc];
}

- (BOOL)isTargetFilename:(NSString*)filename
{
	NSString* ext = [[filename pathExtension] lowercaseString];
	if ([ext isEqualToString:@"png"]) {
		return YES;
	}
	if ([ext isEqualToString:@"gif"]) {
		return YES;
	}
	if ([ext isEqualToString:@"jpg"]) {
		return YES;
	}
	return NO;
}

-(void)setPath:(NSString*)path
{
	NSError* error;
	[_list removeAllObjects];	// **clear**

	NSFileManager* fm = [NSFileManager defaultManager];
	FileEntry* entry;
	for(NSString* filename in [fm contentsOfDirectoryAtPath:path error:&error]) {
		if ([self isTargetFilename:filename]) {
			entry = [[[FileEntry alloc] initWithFilename:filename
					 fileAttributes:[fm fileAttributesAtPath:[path stringByAppendingPathComponent:filename] traverseLink:NO]] autorelease];
			[_list addObject:entry];
		}
	}

	/*
	NSDirectoryEnumerator* dir_enum = [fm enumeratorAtPath:path];
	FileEntry* entry;

	NSString* filename;
	NSDictionary* attrs;
	while (filename = [dir_enum nextObject]) {
		if ([self isTargetFilename:filename]) {
			attrs = [dir_enum fileAttributes];
			if ([[attrs objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]) {
				entry = [[[FileEntry alloc] initWithFilename:filename
										  fileAttributes:attrs] autorelease];
				[_list addObject:entry];
			}
		}
	}
	*/
	[_list sortUsingSelector:@selector(compare:)];
}

- (int)count
{
	return [_list count];
}

- (int)indexWithFilename:(NSString*)filename
{
	int index = 0;
	for (FileEntry* entry in _list) {
		if ([entry.name isEqualToString:filename]) {
			break;
		}
		index++;
	}
	return index;
}

- (FileEntry*)fileEntryAtIndex:(int)index
{
	return [_list objectAtIndex:index];
}

- (void)removeAtIndex:(int)index
{
	if (index >= 0 && index < [_list count]) {
		[_list removeObjectAtIndex:index];
	}
}

@end
