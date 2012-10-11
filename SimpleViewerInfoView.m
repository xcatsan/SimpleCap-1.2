//
//  SimpleViewInfoView.m
//  SimpleCap
//
//  Created by - on 08/12/21.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerInfoView.h"


@implementation SimpleViewerInfoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		NSMutableDictionary*dict = [[NSMutableDictionary alloc] init];
		
		[dict setObject:[NSFont boldSystemFontOfSize:12.0]
				 forKey: NSFontAttributeName];
		[dict setObject:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.00]
				 forKey:NSForegroundColorAttributeName];
		[dict setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.75]
				 forKey:NSStrokeColorAttributeName];
		[dict setObject:[NSNumber numberWithFloat: -1.5]
				 forKey:NSStrokeWidthAttributeName];
		_attribute = dict;
    }
    return self;
}

- (void) dealloc
{
	[_attribute release];
	[_dir_info release];
	[super dealloc];
}

- (void)setRatio:(CGFloat)ratio
{
	_ratio = ratio;
}

#define INFORMATION_OFFSET_X (20.0-7.0)
#define INFORMATION_OFFSET_Y (4.0+6.0)
//#define DIR_INFO_OFFSET_X	12.0
#define DIR_INFO_OFFSET_X	5.0
#define DIR_INFO_OFFSET_Y	INFORMATION_OFFSET_Y


- (NSString*)infoString
{
	int ratio_str = (int)(_ratio*100);
	NSString *info = [NSString stringWithFormat:@"%d%%", ratio_str];
	return info;
}

- (NSSize)infoStringSize
{
	NSSize size = [[self infoString] sizeWithAttributes:_attribute];
	return size;
}

#define META_MARGIN	0
- (void)drawRect:(NSRect)rect {
	
	NSString* info = [self infoString];
	NSSize size = [info sizeWithAttributes:_attribute];
	NSRect bounds = [self bounds];
	NSPoint p = NSMakePoint(bounds.size.width - size.width - INFORMATION_OFFSET_X,
							INFORMATION_OFFSET_Y);
	NSPoint p2 = NSMakePoint(_dir_info_x + DIR_INFO_OFFSET_X, DIR_INFO_OFFSET_Y);
	
	[NSGraphicsContext saveGraphicsState];
	[info drawAtPoint:p withAttributes:_attribute];
	[_dir_info drawAtPoint:p2 withAttributes:_attribute];
	[NSGraphicsContext restoreGraphicsState];
	
	NSRect meta_fill = NSMakeRect(META_MARGIN, 32-META_MARGIN, bounds.size.width-META_MARGIN*2, 21);
	//	[[NSColor colorWithDeviceWhite:0.25 alpha:0.75] set];
	[[NSColor colorWithDeviceRed:0.15 green:0.15 blue:0.2 alpha:0.83] set];
	//[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.75] set];
	NSRectFill(meta_fill);
	
	/*

	
	NSColor* c1 = [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:0.5];
	NSColor* c2 = [NSColor colorWithDeviceRed:0.25 green:0.25 blue:0.25 alpha:0.5];
	NSColor* c3 = c1;

//	NSGradient* g = [[[NSGradient alloc] initWithStartingColor:c1 endingColor:c2] autorelease];
	NSGradient* g = [[[NSGradient alloc] initWithColorsAndLocations:c1, 0.0, c2, 0.5, c3, 1.0, nil] autorelease];
	[g drawInRect:meta_fill angle:-90];
*/
	
	/*
	NSRect meta_frame = bounds;
	meta_frame.origin.x += 1;
	meta_frame.origin.y = 35+20-1;
	meta_frame.size.height = 0.1;
	meta_frame.size.width -= 2;

	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1] set];
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:meta_frame.origin];
	[path lineToPoint:NSMakePoint(meta_frame.origin.x+meta_frame.size.width,
								  meta_frame.origin.y+meta_frame.size.height)];
	[path setLineWidth:0.1];
	NSBezierPath* path= [NSBezierPath bezierPathWithRoundedRect:meta_frame
														xRadius:8.5
														yRadius:8.5];
	 */
//	 [path stroke];
//	NSFrameRect(meta_frame);
}

- (void)setDirectoryInfomation:(NSString*)dir_info
{
	[dir_info retain];
	[_dir_info release];
	_dir_info = dir_info;
}

- (void)setDirInfoOffsetX:(CGFloat)x
{
	_dir_info_x = x;
}

// same code exists other file
- (void)mouseDown:(NSEvent *)theEvent
{
	NSWindow *window = [self window];
	NSPoint origin = [window frame].origin;
	NSPoint old_p = [window convertBaseToScreen:[theEvent locationInWindow]];
	while ((theEvent = [window nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask]) && ([theEvent type] != NSLeftMouseUp)) {
		NSPoint new_p = [window convertBaseToScreen:[theEvent locationInWindow]];
		origin.x += new_p.x - old_p.x;
		origin.y += new_p.y - old_p.y;
		[window setFrameOrigin:origin];
		old_p = new_p;
	}
}

@end
