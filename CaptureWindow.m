//
//  CaptureWindow.m
//  SimpleCap
//
//  Created by - on 08/03/05.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "CaptureWindow.h"

@implementation CaptureWindow

- (id)initWithFrame:(NSRect)frame
{
	
	self = [super initWithContentRect:frame
							styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask|NSUtilityWindowMask
							  backing:NSBackingStoreBuffered
								defer:NO];
	if (self) {
		[self setReleasedWhenClosed:YES];
		[self setDisplaysWhenScreenProfileChanges:YES];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setHasShadow:NO];
//		[self setIgnoresMouseEvents:NO];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	[[self contentView] keyDown:theEvent];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[[self contentView] flagsChanged:theEvent];
}

@end
