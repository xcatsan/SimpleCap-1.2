//
//  CustomButtonCell.m
//  MatrixSample
//
//  Created by - on 09/12/08.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationButtonCell.h"

#define ICON_SIZE		24
#define CELL_SIZE		28
//#define ICON_SIZE		80
//#define CELL_SIZE		82

#pragma mark -
#pragma mark Initialization and Deallocation
@implementation ApplicationButtonCell
@synthesize image, name, cellState, path;

-(id)initWithPath:(NSString*)appPath
{
	self = [super init];
	if (self) {
		LSCopyDisplayNameForURL((CFURLRef)[NSURL fileURLWithPath:appPath], (CFStringRef *)&name);
		self.image = [[NSWorkspace sharedWorkspace] iconForFile:appPath];
		[image setSize:NSMakeSize(ICON_SIZE, ICON_SIZE)];
		cellState = CELL_STATE_OFF;
		self.path = appPath;

	}
	return self;
}
+(ApplicationButtonCell*)cellWithPath:(NSString*)appPath
{
	return [[[ApplicationButtonCell alloc] initWithPath:appPath] autorelease];
}

- (void) dealloc
{
	[image release];
	[path release];
	[name release];
	[super dealloc];
}

#pragma mark -
#pragma mark Overriden methods
- (NSSize)cellSize
{
	return NSMakeSize(CELL_SIZE, CELL_SIZE);
}
- (void)mouseEntered:(NSEvent *)event
{
	NSLog(@"entered");
	cellState = CELL_STATE_OVER;
	[[self controlView] setNeedsDisplay:YES];
}
- (void)mouseExited:(NSEvent *)event
{
	NSLog(@"exited");
	cellState = CELL_STATE_OFF;
	[[self controlView] setNeedsDisplay:YES];
}
- (BOOL)showsBorderOnlyWhileMouseInside
{
	return YES;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// setup drawing point
	NSRect vf = [controlView frame];
	NSSize is = [self.image size];
	NSPoint cp = cellFrame.origin;
	NSSize cs = cellFrame.size;
	cp.y = vf.size.height - cp.y - cs.height;
	cp.x += (cs.width - is.width)/2.0;
	cp.y += (cs.height - is.height)/2.0;

	// draw it
	[controlView lockFocus];

	CGFloat image_fraction;
	NSBezierPath* bp;
	switch (self.cellState) {
		case CELL_STATE_OFF:
			image_fraction = 0.8;
			break;
		case CELL_STATE_ON:
			image_fraction = 1.0;
			[[NSColor colorWithDeviceRed:0.3
								   green:0.3
									blue:0.3
								   alpha:0.5] set];
			bp = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:3 yRadius:3];
			[bp fill];
			break;
		case CELL_STATE_OVER:
			image_fraction = 1.0;
			[[NSColor colorWithDeviceRed:0.6
								   green:0.6
									blue:0.6
								   alpha:0.5] set];
			bp = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:3 yRadius:3];
			[bp fill];
			break;
		default:
			break;
	}
	
	
	NSAffineTransform* xform = [NSAffineTransform transform];
	[xform translateXBy:0.0 yBy:vf.size.height];
	[xform scaleXBy:1.0 yBy:-1.0];
	[xform concat];

	[self.image drawAtPoint:cp
				   fromRect:NSZeroRect
				  operation:NSCompositeSourceOver
				   fraction:image_fraction];
	
	[xform translateXBy:0.0 yBy:0.0];
	[xform scaleXBy:1.0 yBy:1.0];
	[xform concat];

	if (self.cellState == CELL_STATE_ON) {
		[[NSColor colorWithDeviceRed:0.5
							   green:0.5
								blue:0.5
							   alpha:0.5] set];
		bp = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:3 yRadius:3];
		[bp fill];
	}		
	[controlView unlockFocus];
}

 @end
