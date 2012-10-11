//
//  FilenameTextField.m
//  SimpleCap
//
//  Created by - on 09/01/22.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "FilenameTextField.h"
#import "SimpleViewerController.h"

enum {
	STATE_EDITING,
	STATE_LABEL
};

@implementation FilenameTextField

- (void)setStringValue:(NSString *)aString
{
	if (!aString) {
		aString = @"";
	}
/*
	NSMutableAttributedString* attr_str =
		[[[NSMutableAttributedString alloc] initWithString:aString] autorelease];
	[attr_str addAttribute:NSUnderlineStyleAttributeName 
					 value:[NSNumber numberWithFloat:1.0] 
					 range:NSMakeRange(0,[aString length])];
	[attr_str setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [aString length])];
	[super setAttributedStringValue:attr_str];
*/
	[super setStringValue:aString];
}

- (void)setDisable
{
	if ([self isEditable]) {
		[self setDrawsBackground:NO];
		[self setTextColor:[NSColor whiteColor]];
		[self setEditable:NO];
		[self setEnabled:NO];
		[[self window] makeFirstResponder:nil];
		[self setNeedsDisplay:YES];	// important!!
		
		_state = STATE_LABEL;
	}
}

- (id)initWithController:(SimpleViewerController*)controller
{
	self = [super initWithFrame:NSZeroRect];
	if (self) {
		_controller = [controller retain];
		[self setDelegate:_controller];
		[self setBordered:NO];
		[self setEditable:NO];
		[self setEnabled:NO];
		[self setSelectable:NO];
		[self setDrawsBackground:NO];
		[self setTextColor:[NSColor whiteColor]];
		[self setBackgroundColor:[NSColor colorWithDeviceWhite:0.2 alpha:0.9]];
		[self setBezeled:NO];
		[self setFocusRingType:NSFocusRingTypeNone];
		[[self cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[[self cell] setAlignment:NSCenterTextAlignment];
		[self setFont:[NSFont titleBarFontOfSize:12.0]];
		
		_state = STATE_LABEL;
	}
	return self;
}

- (void) dealloc
{
	[_controller release];
	[super dealloc];
}

- (void)startEdit
{
	NSString* filename = [_controller filename];
	if (!filename || [filename isEqualToString:@""]) {
		return;
	}
	filename = [filename lastPathComponent];
	[self setDrawsBackground:YES];
	[self setEditable:YES];
	[self setEnabled:YES];
	[self setEditable:YES];
	[[self window] makeFirstResponder:self];
	NSString* name = [filename stringByDeletingPathExtension];
	[self setStringValue:name];

	_state = STATE_EDITING;
}

- (void)mouseDown:(NSEvent*)theEvent
{
	if ([theEvent clickCount] >= 2) {
		[self startEdit];
		//	[super mouseDown:theEvent];	// do not
		return;
	}

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

- (void)textDidEndEditing:(NSNotification *)notification
{
	if (_state != STATE_LABEL) {
		_state = STATE_LABEL;
		[_controller endEditFilenameIsCancel:NO];
		
		// *NOTICE* must not be inifinite loop !
	}
}
- (BOOL)mouseDownCanMoveWindow
{
	return YES;
}

- (BOOL)isEditing
{
	return (_state == STATE_EDITING);
}

@end
