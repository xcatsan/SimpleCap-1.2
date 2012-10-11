//
//  SimpleViewerImageSubView.m
//  SimpleCap
//
//  Created by - on 09/01/04.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerImageSubView.h"
#import "DialogMessage.h"
#import "UserDefaults.h"

@implementation SimpleViewerImageSubView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_image = nil;
		_interpolation = NSImageInterpolationHigh;
		
		[UserDefaults addObserver:self forKey:UDKEY_VIEWER_IMAGEBOUNDS];
		[UserDefaults addObserver:self forKey:UDKEY_VIEWER_BACKGROUND];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[self setNeedsDisplay:YES];
}

- (void) dealloc
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:UDKEY_VIEWER_IMAGEBOUNDS];
	[_image release];
	[super dealloc];
}

-(void)setImage:(NSImage*)image
{
	[image retain];
	[_image release];
	_image = image;
}

- (NSImage*)image
{
	return _image;
}

- (CGFloat)reductionRatio
{
	CGFloat reduction_ratio;
	NSSize image_size = [_image size];
	NSRect bounds = [self bounds];
	
	CGFloat ratio_w = bounds.size.width / image_size.width;
	CGFloat ratio_h = bounds.size.height / image_size.height;
	reduction_ratio = fminf(ratio_w, ratio_h);
	
	if (reduction_ratio < 1.0) {
		return reduction_ratio;
	} else {
		return 1.0;
	}
}

static CGFloat dasharray[] = {2.0, 2.0};

- (void)drawRect:(NSRect)rect {
	
	if (_image) {
		NSSize image_size = [_image size];
		NSRect bounds = [self bounds];
		
		CGFloat reduction_ratio = [self reductionRatio];
		
		NSSize new_image_size;
		
		if (reduction_ratio < 1.0) {
			new_image_size.width = (int)(image_size.width * reduction_ratio);
			new_image_size.height = (int)(image_size.height * reduction_ratio);
		} else {
			new_image_size = image_size;
		}
		
		NSRect image_rect = NSMakeRect(0.0, 0.0, image_size.width, image_size.height);
		NSRect new_image_rect =
		NSMakeRect(0.0, 0.0, new_image_size.width, new_image_size.height);
		
		new_image_rect.origin.x = (int)((bounds.size.width - new_image_size.width)/2.0);
		new_image_rect.origin.y = (int)((bounds.size.height - new_image_size.height)/2.0);
		
		if ((new_image_rect.origin.x + new_image_rect.size.width) >= bounds.size.width) {
			new_image_rect.size.width -= 0.1;
		}
		if ((new_image_rect.origin.y + new_image_rect.size.height) >= bounds.size.height) {
			new_image_rect.size.height -= 0.1;
		}
		
		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setImageInterpolation:_interpolation];
		[_image drawInRect:new_image_rect
				  fromRect:image_rect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
		[NSGraphicsContext restoreGraphicsState];
		
		// draw image bounds
		BOOL imagebounds = [[UserDefaults valueForKey:UDKEY_VIEWER_IMAGEBOUNDS] boolValue];
		if (imagebounds) {
			int background = [[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue];
	
			new_image_rect.origin.x += 0.1;
			new_image_rect.origin.y += 0.1;
			new_image_rect.size.width -= 0.1;
			new_image_rect.size.height -= 0.1;
			NSBezierPath* path = [NSBezierPath bezierPathWithRect:new_image_rect];
/*			NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:new_image_rect
																 xRadius:4.0 yRadius:4.0];
*/
			[path setLineWidth:1.0];
			NSGraphicsContext* gc = [NSGraphicsContext currentContext];
			[gc saveGraphicsState];
			[gc setShouldAntialias:NO];

			/*
			if (background == 1) {
				[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.25] set];
			} else {
				[[NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:0.25] set];
			}
			[path stroke];
			 */
			switch (background) {
				case 0:
					// black
					[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.5] set];
					[path setLineDash:dasharray count:2 phase:0.0];
					[path stroke];
					break;
				case 1:
					// checkboard
					[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
					[path setLineDash:dasharray count:2 phase:0.0];
					[path stroke];
					
					[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.5] set];
					[path setLineDash:dasharray count:2 phase:2.0];
					[path stroke];
					break;
				case 2:
					// white
					[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
					[path setLineDash:dasharray count:2 phase:0.0];
					[path stroke];
					break;
				default:
					[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
					[path setLineDash:dasharray count:2 phase:0.0];
					[path stroke];
					
					[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.5] set];
					[path setLineDash:dasharray count:2 phase:2.0];
					[path stroke];
					break;
			}
	
			[gc restoreGraphicsState];
		}		
	} else {
		NSString* msg = NSLocalizedString(@"ViewerMsgNoImages", @"");
		NSRect bounds = [self bounds];
		NSSize size = [[DialogMessage defaultMessage] sizeOfMessage:msg];
		NSPoint p = NSMakePoint((bounds.size.width - size.width)/2.0, (bounds.size.height - size.height)/2.0);
		[[DialogMessage defaultMessage] drawMessage:msg atPoint:p];
	}
}

- (void)viewWillStartLiveResize
{
	_interpolation = NSImageInterpolationNone;
}

- (void)viewDidEndLiveResize
{
	_interpolation = NSImageInterpolationHigh;
	[self setNeedsDisplay:YES];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [[self superview] menuForEvent:theEvent];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}
/* can not be called (why?) 2009-02-22 */
- (BOOL)mouseDownCanMoveWindow
{
	return NO;
}

@end
