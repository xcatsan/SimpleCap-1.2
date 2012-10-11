//
//  TimerWindow.m
//  TimerDialog-01
//
//  Created by - on 08/06/08.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "TimerWindow.h"
#import "TimerController.h"

#define OFFSET_X	50
#define OFFSET_Y	(50+22)
@implementation TimerWindow
- (id)initWithController:(TimerController*)controller
{
	_timer_controller = controller;

	NSRect frame;
	
	NSScreen *screen = [NSScreen mainScreen];
	NSRect s_frame = [screen frame];

	frame.size = NSMakeSize(220, 120);
//	frame.origin = NSMakePoint((s_frame.size.width-frame.size.width)/2, (s_frame.size.height-frame.size.height)/2);
//	frame.origin = NSMakePoint((s_frame.size.width-frame.size.width)-OFFSET_X, OFFSET_Y);
//	frame.origin = NSMakePoint((s_frame.size.width-frame.size.width)-OFFSET_X, (s_frame.size.height-frame.size.height)-OFFSET_Y);
//	frame.origin = NSMakePoint((s_frame.size.width-frame.size.width)/2, (s_frame.size.height-frame.size.height)-OFFSET_Y);
//	frame.origin = NSMakePoint(OFFSET_X, (s_frame.size.height-frame.size.height)-OFFSET_Y);
//	frame.origin = NSMakePoint(OFFSET_X, OFFSET_Y);
	frame.origin = NSMakePoint((s_frame.size.width-frame.size.width)/2, OFFSET_Y*2);

	self = [super initWithContentRect:frame
							styleMask:NSTexturedBackgroundWindowMask
							  backing:NSBackingStoreBuffered
								defer:NO];
	if (self) {
		[self setReleasedWhenClosed:YES];
		[self setDisplaysWhenScreenProfileChanges:YES];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setHasShadow:NO];
		[self setLevel:NSScreenSaverWindowLevel+2];
		[self setIgnoresMouseEvents:NO];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	}
	
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	[_timer_controller keyDown:theEvent];
}
- (void)flagsChanged:(NSEvent *)theEvent
{
	[_timer_controller flagsChanged:theEvent];
}

@end
