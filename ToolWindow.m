//
//  ToolWindow.m
//  SimpleCap
//
//  Created by - on 08/06/29.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "ToolWindow.h"


@implementation ToolWindow
- (id)init
{
	NSRect frame = NSZeroRect;
	
	self = [super initWithContentRect:frame
							styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask
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
		//
		[self setAcceptsMouseMovedEvents:YES];
	}
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"keyDown: %@", theEvent);
}


@end
