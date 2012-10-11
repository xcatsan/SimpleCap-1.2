//
//  TimerWindowView.m
//  TimerDialog-01
//
//  Created by - on 08/06/08.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "TimerWindowView.h"
#import "TimerController.h"
#import "ImageFormat.h"

@implementation TimerWindowView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_shadow = [[NSShadow alloc] init];
		[_shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
		[_shadow setShadowBlurRadius:2.0];
		[_shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
    }
    return self;
}

- (void)drawImageFormatDisplay
{
	NSPoint p = NSMakePoint(137, 60);
	[ImageFormat drawImageFormatDisplayAt:p];
}

#define	COUNT_STR_OFFSET	25
- (void)drawRect:(NSRect)rect {
    // Drawing code here.

	NSRect wb = NSZeroRect;
	wb.size = [[self window] frame].size;
	NSBezierPath* path =
		[NSBezierPath bezierPathWithRoundedRect:wb xRadius:15.0 yRadius:15.0];
	
	NSColor* background_color;
	NSColor* foregraound_color;
	
	if ([_controller isRunning]) {
		background_color = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3];
		foregraound_color = [NSColor  whiteColor];
	} else {
		background_color = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.15];
		foregraound_color =[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.8];
	}

	[background_color set];
	[path fill];

	// draw count number
	int count = [_controller lastCount];
	NSPoint p1;
	
	NSMutableAttributedString* str1 =
		[[NSMutableAttributedString alloc]
			initWithString:[NSString stringWithFormat:@"%d", count]];
	[str1 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial" size:64]
				range:NSMakeRange(0, [str1 length])];
	[str1 addAttribute:NSForegroundColorAttributeName value:foregraound_color
				range:NSMakeRange(0, [str1 length])];
	NSSize str_size1 = [str1 size];
	p1.x = (wb.size.width - str_size1.width) /2;
	p1.y = (wb.size.height - str_size1.height) /2 - COUNT_STR_OFFSET;

	// draw title
#define TWV_TITLE_MARGIN_X	7
#define TWV_TITLE_MARGIN_Y	7
#define	TWV_TITLE_HEIGHT	20
	NSPoint p2;
	
	wb.size = [[self window] frame].size;
	wb.origin.x = TWV_TITLE_MARGIN_X;
	wb.origin.y = wb.size.height -TWV_TITLE_MARGIN_Y - TWV_TITLE_HEIGHT;
	wb.size.width -= TWV_TITLE_MARGIN_X*2;
	wb.size.height = TWV_TITLE_HEIGHT;
	background_color = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.2];
	foregraound_color =[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.9];
	path = [NSBezierPath bezierPathWithRoundedRect:wb xRadius:7.5 yRadius:7.5];

	NSMutableAttributedString* str2 =
	[[NSMutableAttributedString alloc] initWithString:[_controller title]];
	[str2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial" size:11]
				 range:NSMakeRange(0, [str2 length])];
	[str2 addAttribute:NSForegroundColorAttributeName value:foregraound_color
				 range:NSMakeRange(0, [str2 length])];
	NSSize str_size2 = [str2 size];
	p2.x = wb.origin.x + (wb.size.width - str_size2.width) /2;
	p2.y = wb.origin.y+2;

	// draw icon
#define TWV_ICON_SIZE	16
#define	TWV_ICON_MARGIN	4
	NSPoint p3 = p2;
	NSImage* image = [_controller image];
	if (image) {
		[image setSize:NSMakeSize(TWV_ICON_SIZE, TWV_ICON_SIZE)];
		p2.x += (TWV_ICON_SIZE+TWV_ICON_MARGIN)/2;
		p3.x -= (TWV_ICON_SIZE+TWV_ICON_MARGIN)/2;
		p3.y += TWV_ICON_SIZE;
	}
	
	// Image format
	[self drawImageFormatDisplay];
	
	// draw
	[NSGraphicsContext saveGraphicsState];
	[_shadow set];
	[background_color set];
	[path fill];
	if (count) {
		[str1 drawAtPoint:p1];
		[str2 drawAtPoint:p2];
	}
	[NSGraphicsContext restoreGraphicsState];
	[image compositeToPoint:p3 operation:NSCompositeSourceOver];
	
	// release
	[str1 release];
	[str2 release];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setTimerController:(TimerController*)controller
{
	[controller retain];
	[_controller release];
	_controller = controller;
}

- (void) dealloc
{
	[_shadow release];
	[_controller release];
	[super dealloc];
}

@end
