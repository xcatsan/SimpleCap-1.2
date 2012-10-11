//
//  DialogMessage.m
//  SimpleCap
//
//  Created by - on 09/01/12.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "DialogMessage.h"


@implementation DialogMessage

- (id)init
{
	self = [super init];
	if (self) {
		NSMutableDictionary*dict = [[NSMutableDictionary alloc] init];
		
		dict = [[NSMutableDictionary dictionary] retain];
		[dict setObject:[NSColor whiteColor]
				 forKey:NSForegroundColorAttributeName];
		[dict setObject:[NSFont boldSystemFontOfSize:14.0]
				 forKey: NSFontAttributeName];
		_attribute = dict;
		
		_shadow = [[NSShadow alloc] init];
		[_shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
		[_shadow setShadowBlurRadius:2.0];
		[_shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
	}
	return self;
}

- (void) dealloc
{
	[_attribute release];
	[_shadow release];
	[super dealloc];
}

static DialogMessage* _default_message = nil;

+ (DialogMessage*)defaultMessage
{
	if (!_default_message) {
		_default_message = [[DialogMessage alloc] init];
	}
	return _default_message;
}

- (NSSize)sizeOfMessage:(NSString*)message
{
	return [message sizeWithAttributes:_attribute];
}

#define BACKGROUND_PADDING_X	10.0
#define BACKGROUND_PADDING_Y	1.5
#define SHADOW_OFFSET			4
- (void)drawMessage:(NSString*)message atPoint:(NSPoint)p
{
	NSRect background_rect;
	NSSize size = [self sizeOfMessage:message];
	background_rect.origin = p;
	background_rect.origin.x -= BACKGROUND_PADDING_X;
	background_rect.origin.y -= BACKGROUND_PADDING_Y;
	background_rect.size = size;
	background_rect.size.width += BACKGROUND_PADDING_X*2;
	background_rect.size.height += BACKGROUND_PADDING_Y*2;
	NSBezierPath* background_path = [NSBezierPath bezierPathWithRoundedRect:background_rect
																	xRadius:11.5
																	yRadius:11.5];
	
	[NSGraphicsContext saveGraphicsState];
	[_shadow set];
	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3] set];
	[background_path fill];
	p.y += 1;
	[message drawAtPoint:p withAttributes:_attribute];
	[NSGraphicsContext restoreGraphicsState];
}

@end
