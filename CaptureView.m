//
//  CaptureView.m
//  SimpleCap
//
//  Created by - on 08/03/05.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "CaptureView.h"
#import "AppController.h"
#import "Handler.h"

@implementation CaptureView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_tracking_area = [[NSTrackingArea alloc] initWithRect:frame
													  options:(NSTrackingMouseMoved |NSTrackingActiveAlways)
														owner:self
													 userInfo:nil];
		[self addTrackingArea:_tracking_area];
			
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	[_handler drawRect:rect];
}

- (void) dealloc
{
	[self removeTrackingArea:_tracking_area];
	[_tracking_area release];
	
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[_handler mouseDown:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[_handler mouseMoved:theEvent];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setHandler:(Handler*)handler
{
	_handler = handler;
}

- (void)keyDown:(NSEvent *)theEvent
{
	[_handler keyDown:theEvent];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[_handler flagsChanged:theEvent];
}


- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [_handler menuForEvent:theEvent];
}


@end
