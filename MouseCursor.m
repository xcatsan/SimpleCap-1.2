//
//  MouseCursor.m
//  MousePointer-3
//
//  Created by - on 08/07/20.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "MouseCursor.h"
#import "UserDefaults.h"
#import <Carbon/Carbon.h>

typedef int CGSConnectionRef;
static CGSConnectionRef connection = 0;
extern CGError CGSNewConnection(void*, CGSConnectionRef*);
extern CGError CGSReleaseConnection(CGSConnectionRef);
extern CGError CGSGetGlobalCursorDataSize(CGSConnectionRef, int*);
extern CGError CGSGetGlobalCursorData(CGSConnectionRef, unsigned char*,int*, int*, CGRect*, CGPoint*, int*, int*, int*);

@implementation MouseCursor

- (NSPoint)convertPoint:(NSPoint)point
{
	NSRect rect = [[NSScreen mainScreen] frame];
	NSPoint p;
	p.y = rect.size.height - point.y;
	p.x = point.x;
	return p;
}

- (void)setupCursor1
{
	_location = [self convertPoint:[NSEvent mouseLocation]];
	NSCursor* cursor = [NSCursor arrowCursor];
	_image = [[cursor image] retain];
	_hot_spot = [cursor hotSpot];
}

- (void)setupCursor2
{
	// mouse location
	_location = [self convertPoint:[NSEvent mouseLocation]];
	
	// cursor image
	int cursorDataSize;
	int cursorRowBytes;
	CGRect cursorRect;
	CGPoint hotSpot;
	int colorDepth;
	int components;
	int cursorBitsPerComponent;
	
	if (CGSNewConnection(NULL, &connection) != kCGErrorSuccess) {
		NSLog(@"CGSNewConnection error.\n");
		return;
	}
	if (CGSGetGlobalCursorDataSize(connection, &cursorDataSize) != kCGErrorSuccess) {
		NSLog(@"CGSGetGlobalCursorDataSize error\n");
		return;
	}
	unsigned char *cursorData = (unsigned char*) malloc(cursorDataSize);
	
	CGError err = CGSGetGlobalCursorData(connection,
										 cursorData,
										 &cursorDataSize,
										 &cursorRowBytes,
										 &cursorRect,
										 &hotSpot,
										 &colorDepth,
										 &components,
										 &cursorBitsPerComponent);
	if (err != kCGErrorSuccess) {
		NSLog(@"CGSGetGlobalCursorData error\n");
		return;
	}

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGDataProviderRef providerRef =
		CGDataProviderCreateWithData(self, cursorData, cursorDataSize, nil);
	
	CGImageRef cgImage = CGImageCreate(cursorRect.size.width,
										  cursorRect.size.height,
										  cursorBitsPerComponent,
										  cursorBitsPerComponent * components,
										  cursorRowBytes,
										  colorSpace,
										  kCGImageAlphaPremultipliedLast,
										  providerRef,
										  nil,
										  NO,
										  kCGRenderingIntentDefault);
	
	NSBitmapImageRep* bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
	_image = [[NSImage alloc] init];
	[_image addRepresentation:bitmapImageRep];
	_hot_spot = NSPointFromCGPoint(hotSpot);

	// 
	[bitmapImageRep release];
	CGImageRelease(cgImage);
	CGDataProviderRelease(providerRef);
	CGColorSpaceRelease(colorSpace);
	CGSReleaseConnection(connection);
	free(cursorData);
}

- (id)init
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (void) dealloc
{
	[_image release];
	[super dealloc];
}


+ (MouseCursor*)mouseCursor
{
	MouseCursor* cursor = [[[MouseCursor alloc] init] autorelease];
	if ([[UserDefaults valueForKey:UDKEY_CURSOR_METHOD] boolValue]) {
		[cursor setupCursor2];
	} else {
		[cursor setupCursor1];
	}
	return cursor;
}

- (NSImage*)image
{
	return _image;
}
- (NSSize)size
{
	return [_image size];
}
- (NSPoint)location
{
	return _location;
}

- (NSPoint)hotSpot
{
	return _hot_spot;
}

- (NSPoint)pointForDrawing
{
	NSPoint p = _location;
	p.y += [self size].height;
	p.x -= _hot_spot.x;
	p.y -= _hot_spot.y;
	
	return p;
}

- (BOOL)isIntersectsRect:(NSRect)rect
{
	NSRect mouseCursorRect = NSZeroRect;
	mouseCursorRect.size = [self size];
	mouseCursorRect.origin = _location;
	
	return NSIntersectsRect(mouseCursorRect, rect);
}
@end
