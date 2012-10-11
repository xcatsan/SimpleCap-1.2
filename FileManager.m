//
//  FileManager.m
//  SimpleCap
//
//  Created by - on 08/03/08.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "FileManager.h"
#import "FileList.h"
#import "UserDefaults.h"
#import "FileEntry.h"
#import "ImageFormat.h"

#define FILENAME_NUMBER_MAX		9999

@implementation FileManager

- (id)init
{
	self = [super init];
	if (self) {
		_file_list = [[FileList alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[_file_list release];
	[super dealloc];
}

- (NSString*)path
{
	NSString *path = [UserDefaults valueForKey:UDKEY_IMAGE_LOCATION];
	return path;
}

- (NSString*)extension
{
	int image_format = [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue];
	NSString* extension;

	switch (image_format) {
		case 1:
			// GIF
			extension = @"gif";
			break;
			
		case 2:
			// JPEG
			extension = @"jpg";
			break;
			
		case 0:
		defaults:
			// PNG
			extension = @"png";
			break;
	}
	return extension;
}

- (int)formatTypeFromFilename:(NSString*)filename
{
	NSString* ext = [filename pathExtension];
	
	if ([ext isEqualToString:@"gif"]) {
		return 1;
	} else if ([ext isEqualToString:@"jpg"]) {
		return 2;
	} else {
		return 0;
	}
}

-(NSString*)serialFilename
{
	return _serial_filename;
}
-(void)setSerialFilename:(NSString*)filename
{
	[filename retain];
	[_serial_filename release];
	_serial_filename = filename;
}

// filename format
// YYMMDD-nnnn.png
//
- (NSString*)nextFilename
{
	int count;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSFileManager *fm = [NSFileManager defaultManager];

	NSString* date = [defaults stringForKey:UDKEY_FILENAME_DATE];
	NSString* current_date = [[NSCalendarDate calendarDate]
					  descriptionWithCalendarFormat:@"%y%m%d"];

	if ([current_date isEqualToString:date]) {
		count = [defaults integerForKey:UDKEY_FILENAME_NUMBER] + 1;
	} else {
		date = current_date;
		[defaults setObject:date forKey:UDKEY_FILENAME_DATE];
		count = 1;
	}

	NSString* path = [self path];
	NSString* extension = [self extension];

	NSString* filename;
	if ((_serial_flag && !_serial_filename) || !_serial_flag) {
		for (; count <= FILENAME_NUMBER_MAX; count++) { 
			filename = [NSString stringWithFormat:@"%@/%@-%04d.%@", path, date, count, extension];
			if (![fm fileExistsAtPath:filename]) {
				break;
			}
		}
		[defaults setInteger:count forKey:UDKEY_FILENAME_NUMBER];
	}
	
	if (_serial_flag) {
		if (!_serial_filename) {
			[self setSerialFilename:filename];
		}
		int subcount;
		NSString* base = [_serial_filename stringByDeletingPathExtension];
		for (subcount=1; subcount <= FILENAME_NUMBER_MAX; subcount++) {
			filename = [NSString stringWithFormat:@"%@-%d.%@", base, subcount, extension];
			if (![fm fileExistsAtPath:filename]) {
				break;
			}
		}
	}

	return filename;
}
// filename format
// YYMMDD-nnnn.png
//

- (NSBitmapImageRep*)fillBackground:(NSBitmapImageRep*)bitmap_rep
{
	NSImage *src_image = [[[NSImage alloc] init] autorelease];
	[src_image addRepresentation:bitmap_rep];
	NSSize image_size = [src_image size];
	
	NSImage *bg_image = [[[NSImage alloc] initWithSize:image_size] autorelease];
	[bg_image lockFocus];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:NSMakeRect(0, 0, image_size.width, image_size.height)];
	[src_image compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	[bg_image unlockFocus];
	NSBitmapImageRep* output = [[[NSBitmapImageRep alloc] initWithData:[bg_image TIFFRepresentation]] autorelease];
	return output;
}

- (void)makeFolder
{
	NSString* path = [self path];
	NSError* error;
	NSFileManager* fm = [NSFileManager defaultManager];
	if (![fm isReadableFileAtPath:path]) {
		[fm createDirectoryAtPath:path
	  withIntermediateDirectories:YES
					   attributes:nil
							error:&error
		 ];
	}
}

- (NSString*)saveImage:(NSBitmapImageRep*)bitmap_rep withFilename:(NSString*)filename
{
	int image_format;

	if (filename) {
		image_format = [self formatTypeFromFilename:filename];
	} else {
		filename = [self nextFilename];
		image_format = [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue];
	}

	NSData* data;

	switch (image_format) {
		case IMAGEFORMAT_GIF:
			// GIF
			bitmap_rep = [self fillBackground:bitmap_rep];
			data = [bitmap_rep representationUsingType:NSGIFFileType
											properties:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], NSImageDitherTransparency, nil]];
			break;
			
		case IMAGEFORMAT_JPEG:
			// JPEG
			bitmap_rep = [self fillBackground:bitmap_rep];
			data = [bitmap_rep representationUsingType:NSJPEGFileType
											properties:[NSDictionary dictionary]];
			break;
			
		case IMAGEFORMAT_PNG:
		defaults:
			// PNG
			data = [bitmap_rep representationUsingType:NSPNGFileType
											properties:[NSDictionary dictionary]];
			break;
			
	}
	
	[self makeFolder];
	[data writeToFile:filename atomically:YES];
	
	return filename;
}

- (NSString*)saveImage:(NSBitmapImageRep*)bitmap_rep

{
	return [self saveImage:bitmap_rep withFilename:nil];
}

// mode
//  0: last file (allow filename nil)
//  1: previous
//  2: next
- (NSString*)filenameInSaveFolderWithCurrentFilename:(NSString*)filename mode:(int)mode
{
	[_file_list setPath:[self path]];

	filename = [filename lastPathComponent];

	int count = [_file_list count];
	_index = [_file_list indexWithFilename:filename];

	NSString* new_filename;
	
	if (mode == 0) {
		_index = count - 1;

	} else if (mode == 1) {
		_index--;
		if (_index < 0) {
			_index = count - 1;
		}
	} else if (mode == 2) {
		_index++;
		if (count <= _index) {
			_index = 0;
		}
	}

	if (count > 0) {
		_current_file = [_file_list fileEntryAtIndex:_index];
		new_filename = [[self path] stringByAppendingPathComponent:_current_file.name];
	} else {
		_current_file = nil;
		new_filename = nil;
	}
	return new_filename;
}
- (NSString*)previousFilenameInSaveFolderWithCurrentFilename:(NSString*)filename
{
	return [self filenameInSaveFolderWithCurrentFilename:filename mode:1];
}

- (NSString*)nextFilenameInSaveFolderWithCurrentFilename:(NSString*)filename
{
	return [self filenameInSaveFolderWithCurrentFilename:filename mode:2];
}
- (NSString*)filenameAfterDeleteFilename:(NSString*)filename
{
	NSString* ret = [self filenameInSaveFolderWithCurrentFilename:filename mode:1];
	return ret;
}

- (NSString*)lastFilename
{
	return [self filenameInSaveFolderWithCurrentFilename:nil mode:0];
}

- (int)index
{
	return _index;
}

- (int)count
{
	return [_file_list count];
}

- (void)moveToTrash:(NSString*)filename
{
	if (!filename) {
		return;
	}
	NSString* dir = [filename stringByDeletingLastPathComponent];
	
	NSArray* files = [NSArray arrayWithObject:[filename lastPathComponent]];
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:dir
											destination:@""
												  files:files
													tag:nil];
	[_file_list removeAtIndex:_index];
	_index--;
	if (_index < 0) {
		_index = 0;
	}
}
- (BOOL)renameFrom:(NSString*)old_path To:(NSString*)new_path;
{
	BOOL result = [[NSFileManager defaultManager]
				   movePath:old_path toPath:new_path handler:nil];
	return result;
}
- (BOOL)isExistPath:(NSString*)path
{
	BOOL result = [[NSFileManager defaultManager]
					fileExistsAtPath:path];
	return result;
}

- (FileEntry*)currentFile
{
	return _current_file;
}

- (void)setSerialFlag:(BOOL)flag
{
	[self setSerialFilename:nil];
	_serial_flag = flag;
}

@end
