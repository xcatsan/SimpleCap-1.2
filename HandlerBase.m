//
//  HandlerBase.m
//  SimpleCap
//
//  Created by - on 08/03/23.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "HandlerBase.h"
#import "CaptureController.h"
#import "Window.h"
#import "UserDefaults.h"
#import "WindowShadow.h"
#import "DesktopWindow.h"
#import "Screen.h"
#import "ImageFormat.h"

@implementation HandlerBase

- (id)initWithCaptureController:(CaptureController*)captureController
{
	self = [super init];
	if (self) {
		_capture_controller = captureController;
	}
	return self;
}

- (void)drawBackground:(NSRect)rect
{
	[[self backgroundColor] set];
	NSRectFill(rect);
}

- (void)keyDown:(NSEvent *)theEvent
{
//	NSLog(@"%@", theEvent);

	// 53 == ESC key
	if ([theEvent keyCode] == 53) {
		[_capture_controller cancel];
	}
	
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	// not implemented
}


- (void)setup
{
	// You should override in subclass
}

- (NSColor*)backgroundColor
{
	return [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3];
}

- (NSInteger)defaultWindowLevel
{
	return NSScreenSaverWindowLevel+1;
}

static CGFloat dasharray[] = {3.0, 3.0};
- (void)drawSelectedBoxRect:(NSRect)rect Counter:(int)counter
{
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect
														 xRadius:5.0 yRadius:5.0];

	[path setLineWidth:1.0];
	
	NSGraphicsContext* gc = [NSGraphicsContext currentContext];
	[gc saveGraphicsState];
	[gc setShouldAntialias:NO];
	
	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3] set];
	[path setLineDash:dasharray count:2 phase:0.0 + counter*4];
	[path stroke];
	
	[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.3] set];
	[path setLineDash:dasharray count:2 phase:3.0 + counter*4];
	[path stroke];
	
	[gc restoreGraphicsState];
}
- (void)drawSelectedBoxRect2:(NSRect)rect Counter:(int)counter
{
#define FRAME_WIDTH	5
#define	PHASE_SEC 30
	int f = counter % PHASE_SEC;
	CGFloat alpha = 0.5 - fabs(sinf((float)f/PHASE_SEC*M_PI))/2.0;
	if (alpha > 0.2) {
		alpha = 0.2;
	}
	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:alpha] set];
	rect.origin.x -= FRAME_WIDTH/2;
	rect.origin.y -= FRAME_WIDTH/2;
	rect.size.width += FRAME_WIDTH;
	rect.size.height += FRAME_WIDTH;
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect
														 xRadius:FRAME_WIDTH/2
														 yRadius:FRAME_WIDTH/2];
	[path setLineWidth:FRAME_WIDTH];
	[path stroke];
}

- (NSArray*)getWindowListWindowID:(CGWindowID)window_id
{
	CFArrayRef ar = CGWindowListCopyWindowInfo((kCGWindowListOptionOnScreenOnly|kCGWindowListOptionOnScreenBelowWindow|kCGWindowListExcludeDesktopElements), window_id);
	NSMutableArray* window_list = [NSMutableArray array];
	
	CFIndex i;
	Window* window;
	CFDictionaryRef wdr;

	for (i=0; i < CFArrayGetCount(ar); i++) {
		wdr = CFArrayGetValueAtIndex(ar, i);
		window = [[[Window alloc] initWithWindowDictionaryRef:wdr] autorelease];
		[window_list addObject:window];
	}
//	CFRelease(ar);
	return window_list;
}

- (NSArray*)getWindowList
{
	return [self getWindowListWindowID:[_capture_controller windowID]];
}
- (NSArray*)getWindowAllList
{
	return [self getWindowListWindowID:kCGNullWindowID];
}

NSInteger window_comparator(Window* window1, Window* window2, void *context)
{
	NSRect rect1 = [window1 rect];
	NSRect rect2 = [window2 rect];

	CGFloat v1, v2;

	if ([(NSNumber*)context boolValue]) {
		v1 = rect1.origin.x;
		v2 = rect2.origin.x;
	} else {
		v1 = rect1.origin.y;
		v2 = rect2.origin.y;
	}
	
	if (v1 < v2) {
		return NSOrderedAscending;
	} else if (v1 > v2) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (NSArray*)getSortedWindowListDirection:(BOOL)direction
{
	NSArray* list = [self getWindowList];
	NSArray* sorted_list =
	[list sortedArrayUsingFunction:window_comparator
						   context:[NSNumber numberWithBool:direction]];
	
	return sorted_list;
}

- (CGImageRef)cgimageWithWindowList:(NSArray*)list cgrect:(CGRect)cgrect
{
	return [self cgimageWithWindowList:list cgrect:cgrect ignoreOptions:NO];
}

- (CGImageRef)cgimageWithWindowList:(NSArray*)list cgrect:(CGRect)cgrect ignoreOptions:(BOOL)ignore
{
	if (list == nil || [list count] == 0) {
		return nil;
	}
	
	BOOL is_shadow = [[UserDefaults valueForKey:UDKEY_WINDOW_SHADOW] boolValue];
	BOOL is_background = [[UserDefaults valueForKey:UDKEY_BACKGROUND] boolValue];

	if (ignore) {
		is_shadow = NO;
		is_background =NO;
	}

	CGWindowImageOption option;
	if (is_shadow) {
		option = kCGWindowImageDefault;
	} else {
		option = kCGWindowImageBoundsIgnoreFraming;
	}

	NSArray* desktop_window_list = [[DesktopWindow sharedDesktopWindow] CGWindowIDlist];
	
	CGWindowID *windowIDs = calloc([list count]+[desktop_window_list count], sizeof(CGWindowID));
	int widx;
	for (widx=0; widx < [list count]; widx++) {
		windowIDs[widx] = [[list objectAtIndex:widx] windowID];
	}
	
	// 1 (order fixed)
	if (is_shadow) {
		if (CGRectIsNull(cgrect)) {
			cgrect = [Window unionCGRectWithWindowList:list];
			cgrect = [WindowShadow addShadowSizeToCGRect:cgrect];
		}
	}

	// 2 (order fixed)
	if (is_background) {
		if (CGRectIsNull(cgrect)) {
			cgrect = [Window unionCGRectWithWindowList:list];
		}
		for (NSNumber* num in desktop_window_list) {
			windowIDs[widx++] = [num unsignedIntValue];
		} 
	}
	
	CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, widx, NULL);
	CGImageRef cgimage = CGWindowListCreateImageFromArray(cgrect, windowIDsArray, option);
	free(windowIDs);
	CFRelease(windowIDsArray);
	
	return cgimage;
}

// ignore 16x16 less
- (Window*)topWindow
{
	Window* top_window = nil;
	for (Window* window in [self getWindowList]) {
		if ([window isNormalWindow:YES]) {
			NSRect rect = [window rect];
			if (rect.size.width > 16.0 && rect.size.height > 16.0) {
				top_window = window;
				break;
			}
		}
	}
	return top_window;
}
- (BOOL)isTargetWindow:(Window*)window
{
	return [window isNormalWindow:NO];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return nil;
}

- (void)setupQuickConfigMenu:(NSMenu*)menu
{
	// not implemented
}


@end
