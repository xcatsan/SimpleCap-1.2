//
//  ThinButton.m
//  Button
//
//  Created by 橋口 - on 08/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThinButton.h"

@implementation ThinButton

- (id)initWithImage:(NSImage*)image1 alterImage:(NSImage*)image2 frame:(NSRect)frame tag:(UInt)tag tooltip:(NSString*)tooltip group:(NSString*)group isActOnMouseDown:(BOOL)is_act_mouse_down;
{
	self = [super init];
	if (self) {
		_image1 = [image1 retain];
		_image2 = [image2 retain];
		_frame = frame;
		_tag = tag;
		_state = TB_STATE_NORMAL;
		_tooltip = tooltip;
		_group = group;
		
		_act_on_mousedown = is_act_mouse_down;
	}
	return self;
}

- (void) dealloc
{
	[_image1 release];
	[_image2 release];
	[super dealloc];
}

- (BOOL)hitAtPoint:(NSPoint)point
{
	return NSPointInRect(point, _frame);
}

- (UInt)state
{
	return _state;
}
- (void)setState:(UInt)state
{
	_state = state;
}


- (NSImage*)image
{
	return _image1;
}
- (NSImage*)alterImage
{
	return _image2;
}

- (NSRect)frame
{
	return _frame;
}

- (UInt)tag
{
	return _tag;
}

- (NSString*)tooltip
{
	return _tooltip;
}

- (NSString*)group
{
	return _group;
}


- (BOOL)isActOnMouseDown
{
	return _act_on_mousedown;
}

@end
