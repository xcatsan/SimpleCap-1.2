//
//  FukidashiWindow.m
//  Fukidashi
//
//  Created by - on 08/12/06.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "FukidashiWindow.h"


@implementation FukidashiWindow

- (id)init
{
	NSRect frame = NSZeroRect;
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
		[self setLevel:NSScreenSaverWindowLevel];
		[self setIgnoresMouseEvents:YES];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	}
	return self;
}

@end
