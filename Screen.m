//
//  Screen.m
//  SimpleCap
//
//  Created by - on 08/07/27.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "Screen.h"


@implementation Screen

- (void)update
{
	NSScreen* screen;
	
	_frame = NSZeroRect;
	for (screen in [NSScreen screens]) {
		NSRect sf = [screen frame];
		_frame = NSUnionRect(_frame, sf);
	}

	NSArray* screen_list = [NSScreen screens];
	_menu_frame = NSZeroRect;
	if ([screen_list count] > 0) {
		screen = [screen_list objectAtIndex:0];
		_menu_frame = [screen frame];
	}
}

static Screen* _screen = nil;
+ (Screen*)defaultScreen
{
	if (!_screen) {
		_screen = [[Screen alloc] init];

		[[NSNotificationCenter defaultCenter] addObserver:_screen
												 selector:@selector(screenChanged:)
													 name:NSApplicationDidChangeScreenParametersNotification
												   object:nil];
		[_screen update];
	}
	return _screen;
}

- (void)screenChanged:(NSNotification *)notification
{
	[self update];
}

- (NSRect)frame;
{
	return _frame;
}

- (NSRect)menuScreenFrame
{
	return _menu_frame;
}

- (CGRect)frameInCGCoordinate
{
	CGRect cgrect = NSRectToCGRect(_frame);
	
	cgrect.origin.y = _menu_frame.size.height
		- (_frame.origin.y + _frame.size.height);
	
	return cgrect;
}


@end
