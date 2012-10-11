//
//  FukidashiView.m
//  Fukidashi
//
//  Created by - on 08/12/05.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "FukidashiView.h"


@implementation FukidashiView

#define BACKGROUND_PADDING_X	10.0
#define BACKGROUND_PADDING_Y	1.5
#define TRIANGLE_HEIGHT			7
#define SHADOW_OFFSET			4

#define OFFSET_X				20

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_string_attributes = [[NSMutableDictionary dictionary] retain];
		[_string_attributes setObject:[NSColor whiteColor]
							 forKey:NSForegroundColorAttributeName];
		[_string_attributes setObject:[NSFont boldSystemFontOfSize:14.0]
							 forKey: NSFontAttributeName];
		
		_message = @"";
		_shadow = [[NSShadow alloc] init];
		[_shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
		[_shadow setShadowBlurRadius:2.0];
		[_shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
    }
    return self;
}

- (NSSize)backgroundSize
{
	NSSize size = [_message sizeWithAttributes:_string_attributes];
	if (size.height < 0) {
		size.height = 22.0;
	}
	size.width += BACKGROUND_PADDING_X*2;
	size.height += BACKGROUND_PADDING_Y*2;
	
	return size;
}

- (NSPoint)trianglePoint
{
	NSSize background_size = [self backgroundSize];
	// -->
	// center
		NSPoint p = NSMakePoint(background_size.width/2, background_size.height+TRIANGLE_HEIGHT+SHADOW_OFFSET);
	// left
//	NSPoint p = NSMakePoint(OFFSET_X, background_size.height+TRIANGLE_HEIGHT+SHADOW_OFFSET);
	// right
	//NSPoint p = NSMakePoint(background_size.width-OFFSET_X-TRIANGLE_HEIGHT/1.5, background_rect.size.height+TRIANGLE_HEIGHT+SHADOW_OFFSET);
	//<--
	return p;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.

	NSRect background_rect = NSZeroRect;
	background_rect.origin.y = SHADOW_OFFSET;
	background_rect.size = [self backgroundSize];
	NSBezierPath* background_path = [NSBezierPath bezierPathWithRoundedRect:background_rect
														 xRadius:11.5
														yRadius:11.5];

	NSBezierPath* triangle_path = [NSBezierPath bezierPath];

	NSPoint triangle_point = [self trianglePoint];
	[triangle_path moveToPoint:triangle_point];
	triangle_point.x += TRIANGLE_HEIGHT/1.5;
	triangle_point.y -= TRIANGLE_HEIGHT;
	[triangle_path lineToPoint:triangle_point];
	triangle_point.x -= (TRIANGLE_HEIGHT/1.5)*2;
	[triangle_path lineToPoint:triangle_point];
	[triangle_path closePath];

	[NSGraphicsContext saveGraphicsState];
	[_shadow set];

	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3] set];
	[background_path fill];
	[triangle_path fill];
	[_message drawAtPoint:NSMakePoint(BACKGROUND_PADDING_X+1, BACKGROUND_PADDING_Y+1+SHADOW_OFFSET) withAttributes:_string_attributes];

	[NSGraphicsContext restoreGraphicsState];
}

- (void)setMessage:(NSString*)message
{
	[message retain];
	[_message release];
	_message = message;
	[self setNeedsDisplay:YES];
}
- (NSSize)areaSize
{
	NSSize size = [self backgroundSize];
	size.width += SHADOW_OFFSET;
	size.height += TRIANGLE_HEIGHT + SHADOW_OFFSET;
	return size;
}

@end
