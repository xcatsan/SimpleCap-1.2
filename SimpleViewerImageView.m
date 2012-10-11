//
//  SimpleViewerView.m
//  SimpleCap
//
//  Created by - on 08/12/21.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerImageView.h"
#import "SimpleViewerImageSubView.h"
#import "SimpleViewerController.h"
#import "UserDefaults.h"

#define TRANSITION_DURATION	0.25

@implementation SimpleViewerImageView

- (id)initWithFrame:(NSRect)frame withController:(SimpleViewerController*)controller {
    self = [super initWithFrame:frame];
    if (self) {
		_controller = [controller retain];
		_current_index = 0;
		_is_transition = NO;

		_image_views = [[NSMutableArray alloc] init];
		[_image_views addObject:
		 [[[SimpleViewerImageSubView alloc] initWithFrame:frame] autorelease]];
		[_image_views addObject:
		 [[[SimpleViewerImageSubView alloc] initWithFrame:frame] autorelease]];

		_transition = [[CATransition animation] retain];
		[_transition setDelegate:self];

		[self setAnimations:
		 [NSDictionary dictionaryWithObject:_transition forKey:@"subviews"]];
		[[self animator] addSubview:[_image_views objectAtIndex:_current_index]];
		[self setWantsLayer:YES];

    }
    return self;
}

- (void) dealloc
{
	[_controller release];
	[_transition release];
	[_subviews release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
}

- (void)setImage:(NSImage*)image withDirection:(int)direction
{
	NSString* tran_type;
	NSString* tran_subtype;
	NSTimeInterval duration = TRANSITION_DURATION;


	switch (direction) {
		case SV_TRANTYPE_NEXT:
			tran_type = kCATransitionPush;
			tran_subtype = kCATransitionFromRight;
			break;
		case SV_TRANTYPE_TRASH:
			tran_type = kCATransitionReveal;
			tran_subtype = kCATransitionFromLeft;
			duration = TRANSITION_DURATION*2;
			break;
		case SV_TRANTYPE_PREVIOUS:
			tran_type = kCATransitionPush;
			tran_subtype = kCATransitionFromLeft;
			break;
		case SV_TRANTYPE_NEW:
			tran_type = kCATransitionMoveIn;
			tran_subtype = kCATransitionFromTop;
			duration = TRANSITION_DURATION*2;
			break;
		case SV_TRANTYPE_OPEN:
			tran_type = kCATransitionFade;
			tran_subtype = kCATransitionFromRight;
			duration = TRANSITION_DURATION*2;
			break;
		case SV_TRANTYPE_UPDATE:
			tran_type = kCATransitionFade;
			tran_subtype = kCATransitionFromTop;
			duration = TRANSITION_DURATION*2;
			break;
		case SV_TRANTYPE_NONE:
		default:
			tran_type = kCATransitionPush;
			tran_subtype = kCATransitionFromTop;
			break;
	}
	[_transition setDuration:duration];
	[_transition setType:tran_type];
	[_transition setSubtype:tran_subtype];

	if (_is_transition) {
		int next_index = (_current_index + 1) % 2;
		[[_image_views objectAtIndex:next_index] setImage:image];
		[[self animator] replaceSubview:[_image_views objectAtIndex:_current_index]
								   with:[_image_views objectAtIndex:next_index]];
		_current_index = next_index;
	} else {
		[[_image_views objectAtIndex:_current_index] setImage:image];
		_is_transition = YES;
	}

}

- (NSImage*)image
{
	return 	[[_image_views objectAtIndex:_current_index] image];
}
- (CGFloat)reductionRatio
{
	return 	[[_image_views objectAtIndex:_current_index] reductionRatio];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	
	frame.origin = NSZeroPoint;
	for (NSView* view in [self subviews]) {
		[view setFrame:frame];
	}
}

- (void)setNeedsDisplay:(BOOL)flag
{
	[super setNeedsDisplay:flag];
	
	for (NSView* view in [self subviews]) {
		[view setNeedsDisplay:flag];
	}
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [_controller menuForEvent:theEvent];
}


- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
	[_controller copyFileTo:dropDestination];
	return [NSArray arrayWithObject:[[_controller filename] lastPathComponent]];
}
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
//	NSLog(@"%@", type);
	if ([type isEqualToString:NSTIFFPboardType]) {
		[sender setData:[[self image] TIFFRepresentation] forType:NSTIFFPboardType];
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSImage* image = [self image];
	NSString* filename = [_controller filename];
	CGFloat ratio = [self reductionRatio];
	NSRect bounds = [self bounds];
	
	NSRect image_rect = NSZeroRect;
	image_rect.size.width = image.size.width * ratio;
	image_rect.size.height = image.size.height * ratio;
	image_rect.origin.x = (int)((bounds.size.width - image_rect.size.width)/2.0);
	image_rect.origin.y = (int)((bounds.size.height - image_rect.size.height)/2.0);
	
	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if (NSPointInRect(p, image_rect)) {

		NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
		[pboard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, NSFilesPromisePboardType, nil] owner:self];
		
		[pboard setPropertyList:[NSArray arrayWithObject:[filename pathExtension]]
						forType:NSFilesPromisePboardType];
		/*
		[pboard setPropertyList:[NSArray arrayWithObject:filename]
						forType:NSFilenamesPboardType];
		[pboard setString:[[NSURL fileURLWithPath:filename] absoluteString] forType:NSStringPboardType];
		// can not work below for Safari
		[[NSURL fileURLWithPath:filename] writeToPasteboard:pboard];
		*/

		NSImage *dragged_image = [[[NSImage alloc] initWithSize:image_rect.size] autorelease];
		[dragged_image lockFocus];
		[image drawInRect:NSMakeRect(0, 0, image_rect.size.width, image_rect.size.height)
				 fromRect:NSMakeRect(0, 0, image.size.width, image.size.height)
				operation:NSCompositeSourceOver
				 fraction:0.5f];
		[dragged_image unlockFocus];
		
		[self dragImage:dragged_image
					 at:NSMakePoint((bounds.size.width - image_rect.size.width)/2.0, (bounds.size.height - image_rect.size.height)/2.0)
				 offset:NSZeroSize
				  event:theEvent
			 pasteboard:pboard
				 source:self
			  slideBack:YES];
	} else {
		// same code exists other file
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
}
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationCopy;
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
