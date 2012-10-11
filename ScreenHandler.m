//
//  TimerScreen.m
//  SimpleCap
//
//  Created by - on 08/03/23.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "ScreenHandler.h"
#import "CaptureController.h"
#import "TimerController.h"
#import "UserDefaults.h"
#import "DesktopWindow.h"
#import "Screen.h"

@implementation ScreenHandler

// for protocol
- (void)reset
{
}

- (BOOL)startWithObject:(id)object
{
	[_capture_controller disableMouseEventInWindow];
	_animation_counter = 0;
	[_capture_controller startTimerOnClient:self
									  title:NSLocalizedString(@"TimerTitleScreen", @"")
									  image:nil];
	return YES;
}


- (void)tearDown
{
	[_capture_controller enableMouseEventInWindow];
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] set];
	NSRectFill(rect);
	
	for (NSScreen* screen in [NSScreen screens]) {
		NSRect frame = [screen frame];
		frame.origin = [[_capture_controller view] convertPoint:[[_capture_controller window] convertScreenToBase:frame.origin] fromView:nil];
		frame.origin.y -= frame.size.height;
		frame.size.width -= 0.1;
		frame.origin.y += 0.1;
		frame.size.height -= 0.1;
		
		[self drawSelectedBoxRect:frame Counter:_animation_counter];
	}
}

- (void)mouseMoved:(NSEvent *)theEvent
{
}

- (void)mouseDown:(NSEvent *)theEvent
{
}

- (void)keyDown:(NSEvent *)theEvent
{
	[super keyDown:theEvent];
}

- (NSInteger)windowLevel
{
	return [super defaultWindowLevel]+1;
}


//
// <TimerClient>
//
- (void)timerStarted:(TimerController*)controller
{
}

- (void)timerCounted:(TimerController*)controller
{
	_animation_counter++;
	CaptureView* view = [_capture_controller view];
	[view setNeedsDisplay:YES];
}

- (void)timerFinished:(TimerController*)controller
{
	BOOL is_exclude_desktop_icons = [[UserDefaults valueForKey:UDKEY_SCREEN_EXCLUDE_ICONS] boolValue];

	CGWindowImageOption option = kCGWindowListOptionOnScreenBelowWindow;
	if (is_exclude_desktop_icons) {
		option |= kCGWindowListExcludeDesktopElements;
	}

	CGImageRef cgimage = CGWindowListCreateImage([[Screen defaultScreen] frameInCGCoordinate],	// NG)CGRectInfinite for 10.6
												 option,
												 [_capture_controller windowID],
												 kCGWindowImageDefault);
//	[_capture_controller saveImage:cgimage];
	
	NSRect rect = [[NSScreen mainScreen] frame];

	// draw desktop
	if (is_exclude_desktop_icons) {
		// change to NSImage
		NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithCGImage:cgimage] autorelease];
		NSImage* src_image = [[[NSImage alloc] init] autorelease];
		[src_image addRepresentation:bitmap];
		
		NSArray* desktop_window_list = [[DesktopWindow sharedDesktopWindow] CGWindowIDlist];
		CGWindowID *windowIDs = calloc([desktop_window_list count], sizeof(CGWindowID));
		int widx = 0;
		for (NSNumber* num in desktop_window_list) {
			windowIDs[widx++] = [num unsignedIntValue];
		}
		CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, widx, NULL);
		CGImageRef cgimage_desktop = CGWindowListCreateImageFromArray(NSRectToCGRect(rect), windowIDsArray, kCGWindowImageDefault);
		NSBitmapImageRep *bitmap_desktop = [[[NSBitmapImageRep alloc] initWithCGImage:cgimage_desktop] autorelease];
		NSImage* image_desktop = [[[NSImage alloc] init] autorelease];
		[image_desktop addRepresentation:bitmap_desktop];
		[image_desktop lockFocus];
		[src_image drawAtPoint:NSZeroPoint
					  fromRect:NSZeroRect
					 operation:NSCompositeSourceOver fraction:1.0];
		[image_desktop unlockFocus];
		src_image = image_desktop;
		
		// restore to CGImage
		NSBitmapImageRep *out_bitmap = [NSBitmapImageRep imageRepWithData:[src_image TIFFRepresentation]];
		
		CGImageRelease(cgimage);
		cgimage = [out_bitmap CGImage];
		CGImageRetain(cgimage);
	}
	/*
	 link: http://lists.apple.com/archives/cocoa-dev/2009/Sep/msg00776.html
	 09/9/7 9:46:46	GrowlHelperApp[187]	*** attempt to pop an unknown autorelease pool (0x11a0200)
	 09/9/7 9:46:52	[0x0-0xa70a7].com.xcatsan.SimpleCap[1199]	Mon Sep  7 09:46:52 keizointel-2.local SimpleCap[1199] <Error>: CGImageCreate: invalid image bits/pixel or bytes/row.
	 09/9/7 9:46:52	SimpleCap[1199]	*** Assertion failure in -[NSBitmapImageRep initWithCGImage:], /SourceCache/AppKit/AppKit-1038/AppKit.subproj/NSBitmapImageRep.m:1245
	 09/9/7 9:46:52	SimpleCap[1199]	Invalid parameter not satisfying: cgImage != NULL
	 09/9/7 9:47:07	SimpleCap[1199]	*** Assertion failure in -[NSBitmapImageRep initWithCGImage:], /SourceCache/AppKit/AppKit-1038/AppKit.subproj/NSBitmapImageRep.m:1245
	 09/9/7 9:47:07	SimpleCap[1199]	Invalid parameter not satisfying: cgImage != NULL
	 09/9/7 9:47:07	[0x0-0xa70a7].com.xcatsan.SimpleCap[1199]	Mon Sep  7 09:47:07 keizointel-2.local SimpleCap[1199] <Error>: CGImageCreate: invalid image bits/pixel or bytes/*/
	
	if ([controller isCopy]) {
		[_capture_controller copyImage:cgimage withMouseCursorInRect:rect imageFrame:NSZeroRect];
		[_capture_controller exit];
		
	} else if ([controller isContinous]) {
		[_capture_controller setContinouslyFlag:YES];
		[_capture_controller saveImage:cgimage withMouseCursorInRect:rect imageFrame:NSZeroRect];
		[controller start];
		
	} else {
		// NORMAL
		[_capture_controller saveImage:cgimage withMouseCursorInRect:rect imageFrame:NSZeroRect];
		[_capture_controller openViewerWithLastfile];
		[_capture_controller exit];
	}
}

- (void)timerCanceled:(TimerController*)controller
{
	[_capture_controller cancel];
}

- (void)timerPaused:(TimerController*)controller
{
}

- (void)timerRestarted:(TimerController*)controller
{
}

- (void)openConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	[_capture_controller openScreenConfigMenuWithView:view event:event];
}


- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [super menuForEvent:theEvent];
}

- (void)setupQuickConfigMenu:(NSMenu*)menu
{
	[super setupQuickConfigMenu:menu];
}

- (void)changedImageFormatTo:(int)image_format
{
}

@end
