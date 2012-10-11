//
//  ApplicationHandler.m
//  SimpleCap
//
//  Created by - on 08/07/02.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationHandler.h"
#import "CaptureController.h"
#import "TimerController.h"
#import "Window.h"

@implementation ApplicationHandler

// for protocol
- (void)reset
{
}

- (void)setup
{
	// setup array
	_app_windows = [[NSMutableArray alloc] init];
}

- (BOOL)startWithObject:(id)object
{
	_application = [object retain];
	[_capture_controller disableMouseEventInWindow];
	_animation_counter = 0;
	[_capture_controller startTimerOnClient:self
									  title:[_application objectForKey:@"name"]
									  image:[_application objectForKey:@"image"]];
	return YES;
}

- (void) dealloc
{
	[_app_windows release];
	[super dealloc];
}

- (void)tearDown
{
	[_application release];
	[_capture_controller enableMouseEventInWindow];
	[_app_windows removeAllObjects];
}

- (void)drawRect:(NSRect)rect
{
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

- (CGImageRef)capture
{
	return [self cgimageWithWindowList:_app_windows
								cgrect:CGRectNull];
}

- (void)setAppWindows
{
	int pid = [[_application objectForKey:@"pid"] intValue];
	for(Window* window in [self getWindowAllList]) {
		
		if (pid == [window ownerPID]) {
			[_app_windows addObject:window];
		}
	}
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
	[self setAppWindows];
	/*
	[_capture_controller saveImage:[self capture]
	   withMouseCursorInWindowList:_app_windows
						imageFrame:[Window unionNSRectWithWindowList:_app_windows]];
	[_capture_controller exit];
	 */
	if ([controller isCopy]) {
		[_capture_controller copyImage:[self capture]
		   withMouseCursorInWindowList:_app_windows
							imageFrame:[Window unionNSRectWithWindowList:_app_windows]];
		[_capture_controller exit];
		
	} else if ([controller isContinous]) {
		[_capture_controller setContinouslyFlag:YES];
		[_capture_controller saveImage:[self capture]
		   withMouseCursorInWindowList:_app_windows
							imageFrame:[Window unionNSRectWithWindowList:_app_windows]];
		[controller start];
		
	} else {
		// NORMAL
		[_capture_controller saveImage:[self capture]
		   withMouseCursorInWindowList:_app_windows
							imageFrame:[Window unionNSRectWithWindowList:_app_windows]];
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
	[_capture_controller openWindowConfigMenuWithView:view event:event];
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
