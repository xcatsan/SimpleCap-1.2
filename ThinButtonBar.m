//
//  ThinButtonBar.m
//  Button
//
//  Created by hashi on 08/05/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThinButtonBar.h"
#import "ThinButton.h"
#import "Screen.h"

#define TB_MARGIN_WIDTH	2.0

@implementation ThinButtonBar

static NSShadow* _shadow = nil;

-(id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_list = [[NSMutableArray alloc] init];
		_group_list = [[NSMutableDictionary alloc] init];
		_is_shadow = YES;
		
		_offsetX = 1.0;
		_offsetY = 1.0;
		_marginY = 0.0;
		_draw_offset = NSZeroPoint;

		if (!_shadow) {
			_shadow = [[NSShadow alloc] init];
			[_shadow setShadowOffset:NSMakeSize(1.5, -1.5)];
			[_shadow setShadowBlurRadius:2.0];
			[_shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
		}
		
		_tracking_area = nil;
		_delegate = nil;
		
		_position = SC_BUTTON_POSITION_RIGHT_TOP;
		_popup_menu_mode = NO;
		_while_flasher = NO;
	}
	return self;

}
- (void)setDrawOffset:(NSPoint)offset
{
	_draw_offset = offset;
}

#define SIZE_MARGIN	3
- (void)addButtonWithImageResource:(NSString*)resource alterImageResource:(NSString*)resource2 tag:(UInt)tag tooltip:(NSString*)tooltip group:(NSString*)group isActOnMouseDown:(BOOL)is_act_mouse_down;
{
	//
	// setup ThinButton object
	//
	NSImage *image1 = [[[NSImage alloc]
					   initWithContentsOfFile:[[NSBundle mainBundle]
											   pathForImageResource:resource]] autorelease];
	NSImage *image2 = [[[NSImage alloc]
					   initWithContentsOfFile:[[NSBundle mainBundle]
											   pathForImageResource:resource2]] autorelease];
	
//	[image1 setFlipped:YES];
//	[image2 setFlipped:YES];

	NSMutableArray* buttons = nil;
	NSRect frame;

	if (group) {
		buttons = [_group_list objectForKey:group];
	}
	if (buttons && [buttons count] > 0) {
		frame = [[buttons objectAtIndex:0] frame];
	} else {
		frame.origin.x = _offsetX;
		frame.origin.y = _offsetY;
		frame.size = [image1 size];
		frame.size.width += SIZE_MARGIN;
		frame.size.height += SIZE_MARGIN;
	}

	ThinButton *button = [[[ThinButton alloc] initWithImage:image1
												 alterImage:image2
													  frame:frame
														tag:tag
													tooltip:tooltip
													  group:group
										   isActOnMouseDown:is_act_mouse_down
						   ] autorelease];

	if (buttons) {
		[buttons addObject:button];
		
	} else {
		[_list addObject:button];

		if (group) {
			buttons = [NSMutableArray arrayWithObject:button];
			[_group_list setObject:buttons forKey:group];
		}
		
		//
		// managing offset and frame
		//
		_offsetX += frame.size.width + TB_MARGIN_WIDTH;
		
		NSSize new_size = [self frame].size;
		new_size.width = _offsetX;
		if (new_size.height < frame.size.height) {
			new_size.height = frame.size.height;
		}
		[self setFrameSize:new_size];
		
		
		//
		// rearrange tracking area
		//
		if (_tracking_area) {
			[self removeTrackingArea:_tracking_area];
			[_tracking_area release];
		}
		
		NSRect tracking_rect = [self frame];
		tracking_rect.origin = NSZeroPoint;
		_tracking_area = [[NSTrackingArea alloc] initWithRect:tracking_rect
													  options:(NSTrackingMouseEnteredAndExited |
															   NSTrackingMouseMoved |
															   NSTrackingActiveAlways)
														owner:self
													 userInfo:nil];
		[self addTrackingArea:_tracking_area];
		
		//
		// Add tooltip
		//
		[self addToolTipRect:frame owner:self userData:nil];
		
		//
		// redraw
		//
		[self setHidden:YES];
		//	[self setNeedsDisplay:YES];	
	}
	
}


- (void) dealloc
{
	[self removeAllToolTips];
	[_list release];
	[_group_list release];

	if (_tracking_area) {
		[self removeTrackingArea:_tracking_area];
		[_tracking_area release];
	}
	
	[_delegate release];
	[super dealloc];
}


- (void)drawRect:(NSRect)rect {
	[NSGraphicsContext saveGraphicsState];
	if (_is_shadow) {
		[_shadow set];
	}

	NSImage *image;
	CGFloat alpha;

	NSAffineTransform* xform = [NSAffineTransform transform];
	[xform translateXBy:0.0 yBy:[self bounds].size.height];
	[xform scaleXBy:1.0 yBy:-1.0];
	[xform concat];
	
	if (_while_flasher) {
		for (ThinButton *button in _list) {
			image = [button image];
			[image drawAtPoint:[button frame].origin
					  fromRect:NSZeroRect
					 operation:NSCompositeSourceOver
					  fraction:_flasher_alpha];
		}

	} else {
		for (ThinButton *button in _list) {
			switch ([button state]) {
				case TB_STATE_NORMAL:
					image = [button alterImage];
					alpha = 1.0;
					break;
				case TB_STATE_OVER:
					alpha = 1.0;
					image = [button image];
					break;
				case TB_STATE_PUSHED:
					alpha = 0.75;
					image = [button image];
					break;
			}
			
			[image drawAtPoint:[button frame].origin
					  fromRect:NSZeroRect
					 operation:NSCompositeSourceOver
					  fraction:alpha];
		}
		/*
	CGFloat alpha;
	for (ThinButton *button in _list) {
		switch ([button state]) {
			case TB_STATE_NORMAL:
				alpha =  0.75;
				break;
			case TB_STATE_OVER:
				alpha = 1.0;
				break;
			case TB_STATE_PUSHED:
				alpha = 0.75;
				break;
		}
		
		[[button image] drawAtPoint:[button frame].origin
						   fromRect:NSZeroRect
						  operation:NSCompositeSourceOver
						   fraction:alpha];
	*/
	}
	[NSGraphicsContext restoreGraphicsState];
}

- (ThinButton*)changeState:(UInt)state withEvent:(NSEvent*)theEvent
{
	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	ThinButton* hitButton = nil;
	for (ThinButton* button in _list) {
		if ([button hitAtPoint:p]) {
			hitButton = button;
			[button setState:state];
		} else {
			[button setState:TB_STATE_NORMAL];
		}
	}
	[self setNeedsDisplay:YES];
	return hitButton;
}

- (void)mouseEntered:(NSEvent *)theEvent {

	[self changeState:TB_STATE_OVER withEvent:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
	if (!_pushed_button) {
		[self changeState:TB_STATE_NORMAL withEvent:theEvent];
	}
}

- (void)mouseMoved:(NSEvent *)theEvent {
	[self changeState:TB_STATE_OVER withEvent:theEvent];
}

- (void)exchangeButtonFrom:(ThinButton*)old To:(ThinButton*)new
{
	NSUInteger i;
	for (i=0; i < [_list count]; i++) {
		if ([_list objectAtIndex:i] == old) {
			[_list replaceObjectAtIndex:i withObject:new];
			break;
		}
	}
}

- (void)resetGroup:(NSString*)group
{
	NSArray* group_array = [_group_list objectForKey:group];
	if (group_array && [group_array count] > 0) {
		ThinButton *new = [group_array objectAtIndex:0];
		NSArray *_copy_list = [[_list copy] autorelease];
		for (ThinButton *old in _copy_list) {
			if ([group isEqualToString:[old group]]) {
				[self exchangeButtonFrom:old To:new];
				[old setState:TB_STATE_NORMAL];
			}
		}
	}
}
- (void)switchGroup:(NSString*)group
{
	NSArray* group_array = [_group_list objectForKey:group];
	
	if (group_array) {
		ThinButton* old = nil;
		ThinButton* new = nil;
		
		for(old in _list) {
			if ([group isEqualToString:[old group]]) {
				break;
			}
		}
		if (old) {
			NSUInteger i = 0;
			ThinButton* button;
			for (button in group_array) {
				i++;
				if (button == old) {
					break;
				}
			}
			if (i == [group_array count]) {
				i = 0;
			}
			new = [group_array objectAtIndex:i];
			[self exchangeButtonFrom:old To:new];
			[old setState:TB_STATE_NORMAL];
			[new setState:TB_STATE_NORMAL];
		}
	}
}

//--------------------
// Menu handlings -->
//--------------------
- (void)setPopupMenuMode:(BOOL)mode
{
	_popup_menu_mode = mode;
}

/*
- (void)selectMenuItem:(NSMenuItem *)menu_item
{
	[_delegate performSelector:@selector(selectMenuAtTag:atIndex:)
					withObject:[menu_item representedObject]
					withObject:[NSNumber numberWithInt:[menu_item tag]]];
}
*/

/*
- (void)displayMenuWithTag:(UInt)tag event:(NSEvent*)theEvent
{
	NSNumber* tag_number = [NSNumber numberWithInt:tag];
	NSArray* list = [_delegate performSelector:@selector(menuWithTag:) 
									withObject:tag_number];
	NSMenu* menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	NSMenuItem* item;
	NSInteger idx = 0;
	
	for (NSString* title in list) {
		item = [[[NSMenuItem alloc] initWithTitle:title
										   action:@selector(selectMenuItem:)
									keyEquivalent:@""] autorelease];
		[item setTag:idx++];
		[item setRepresentedObject:tag_number];
		[menu addItem:item];
	}
	if (idx == 0) {
		[menu insertItemWithTitle:NSLocalizedString(@"SelectionHistoryNone", @"")
						   action:nil
					keyEquivalent:@""
						  atIndex:0];
	}

	[NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
}
*/

//--------------------
// <-- Menu Handlings
//--------------------

- (void)actButton:(ThinButton*)button withEvent:(NSEvent*)theEvent
{
	
	if (button == _pushed_button) {
		if (button && [_delegate respondsToSelector:@selector(clickedAtTag:event:)]) {
			[_delegate performSelector:@selector(clickedAtTag:event:) 
							withObject:[NSNumber numberWithInt:[button tag]]
							withObject:theEvent];
			//			[self switchGroup:[hitButton group]];
		}
	}
}
- (void)mouseDown:(NSEvent *)theEvent {

	_pushed_button = [self changeState:TB_STATE_PUSHED withEvent:theEvent];
	if ([_pushed_button isActOnMouseDown]) {
		[self actButton:_pushed_button withEvent:theEvent];
	}

	/*
	if (_popup_menu_mode) {
		ThinButton *hitButton = [self changeState:TB_STATE_OVER withEvent:theEvent];
		if (hitButton && [_delegate respondsToSelector:@selector(menuWithTag:)]) {
			[self switchGroup:[hitButton group]];
			[self displayMenuWithTag:[hitButton tag] event:theEvent];
		}
		_pushed_button = nil;
	} else {
		_pushed_button = [self changeState:TB_STATE_PUSHED withEvent:theEvent];
	}
	 */
}


- (void)mouseUp:(NSEvent *)theEvent {
	ThinButton *hitButton = [self changeState:TB_STATE_OVER withEvent:theEvent];

	if ([_pushed_button isActOnMouseDown]) {
	} else {
		[self actButton:hitButton withEvent:theEvent];
	}
	_pushed_button = nil;
}

- (void)setDelegate:(id)delegate
{
	[delegate retain];
	[_delegate release];
	_delegate = delegate;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setFrameOrigin:(NSPoint)p
{
	p.x = floor(p.x);
	p.y = floor(p.y);
	[super setFrameOrigin:p];
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
	for(ThinButton* button in _list) {
		if (NSPointInRect(point, [button frame])) {
			return [button tooltip];
		}
	}
	return @"non";
}

- (void)reset
{
	_pushed_button = nil;
	_while_flasher = NO;
	for (ThinButton *button in _list) {
		[button setState:TB_STATE_NORMAL];
	}
	[self setNeedsDisplay:YES];
}

#define SBBF_MARGIN 10.0
#define BUTTON_OFFSET 10.0
-(void)setButtonBarWithFrame:(NSRect)frame
{
	NSPoint p;
	NSSize button_size = [self bounds].size;
	
	NSSize view_size = [[Screen defaultScreen] frame].size;

	// (1) standard position
	switch (_position) {
		case SC_BUTTON_POSITION_CENTER:
			p.x = frame.origin.x + frame.size.width  /2.0 - button_size.width  /2.0;
			p.y = frame.origin.y + frame.size.height /2.0 - button_size.height /2.0;
			break;
		case SC_BUTTON_POSITION_CENTER_BOTTOM:
			p.x = frame.origin.x + frame.size.width  /2.0 - button_size.width  /2.0;
			p.y = frame.origin.y + frame.size.height - button_size.height -BUTTON_OFFSET;
			break;
		case SC_BUTTON_POSITION_LEFT_TOP:
			p.x = frame.origin.x + BUTTON_OFFSET;
			p.y = frame.origin.y + BUTTON_OFFSET;
			break;
		case SC_BUTTON_POSITION_RIGHT_TOP:
			p.x = frame.origin.x + frame.size.width  - button_size.width - BUTTON_OFFSET;
			p.y = frame.origin.y + BUTTON_OFFSET;
			break;
		case SC_BUTTON_POSITION_LEFT_BOTTOM:
			p.x = frame.origin.x + BUTTON_OFFSET;
			p.y = frame.origin.y + frame.size.height - button_size.height -BUTTON_OFFSET;
			break;
		case SC_BUTTON_POSITION_RIGHT_BOTTOM:
			p.x = frame.origin.x + frame.size.width  - button_size.width - BUTTON_OFFSET;
			p.y = frame.origin.y + frame.size.height - button_size.height -BUTTON_OFFSET;
			break;
	}
	
	// (2) over height/width
	if (button_size.height + SBBF_MARGIN*2 > frame.size.height ||
		button_size.width  + SBBF_MARGIN*2 > frame.size.width) {
		p.y = frame.origin.y + frame.size.height + BUTTON_OFFSET;

		if (p.y + button_size.height + SBBF_MARGIN > view_size.height) {
			p.y = frame.origin.y - button_size.height - BUTTON_OFFSET;
		}
	}
	if (p.x + button_size.width + SBBF_MARGIN > view_size.width) {
		p.x = view_size.width - button_size.width - BUTTON_OFFSET;
	}
	if (p.y + button_size.height + SBBF_MARGIN > view_size.height) {
		p.y = view_size.height - button_size.height - BUTTON_OFFSET;
	}
	
	// (3) adjust origin.x
	if (p.x - SBBF_MARGIN < frame.origin.x) {
		p.x = frame.origin.x - BUTTON_OFFSET;
	}
	if (p.x + button_size.width + SBBF_MARGIN > view_size.width) {
		p.x = frame.origin.x + frame.size.width  - button_size.width + BUTTON_OFFSET;
	}
	if (p.x < 0) {
		p.x = BUTTON_OFFSET;
	}
	
	p.y += _marginY;
	
	p.x += _draw_offset.x;
	p.y += _draw_offset.y;
	
	[self setFrameOrigin:p];
}

-(void)setPosition:(int)position
{
	_position = position;
}

- (void)show
{
	[self setHidden:NO];
}
- (void)hide
{
	[self reset];
	[self setHidden:YES];
}

- (void)setShadow:(BOOL)is_shadow
{
	_is_shadow = is_shadow;
}

- (void)setMarginY:(CGFloat)marginY
{
	_marginY = marginY;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}
- (BOOL)mouseDownCanMoveWindow
{
	return NO;
}

//-----------------
// Flasher
//-----------------
#define	FLASHER_INTERVAL	0.05
#define	FLASHER_FRAMES		10.0
- (void)flasherAnimate:(NSTimer*)timer
{
	// do it
	[self setNeedsDisplay:YES];
	
	if (_flasher_step == 0) {
		_flasher_alpha += 1.0/FLASHER_FRAMES;
		if (_flasher_alpha > 1.25) {
			_flasher_step = 1;
		}
	} else if (_flasher_step == 1) {
		_flasher_alpha -= 1.0/FLASHER_FRAMES;
		if (_flasher_alpha <= 0.5) {
			[timer invalidate];
			_while_flasher = NO;
		}
	}
}

- (void)startFlasher
{
	if (_while_flasher) {
		if ([_flasher_timer isValid]) {
			[_flasher_timer invalidate];
		}
	}
	_flasher_alpha = 0.0;
	_while_flasher = YES;
	_flasher_step = 0;
	_flasher_timer = [NSTimer timerWithTimeInterval:FLASHER_INTERVAL
											 target:self
										   selector:@selector(flasherAnimate:)
										   userInfo:nil
											repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:_flasher_timer forMode:NSRunLoopCommonModes];
}

- (void)update
{
	[self setNeedsDisplay:YES];
}

- (NSSize)size
{
	return NSMakeSize(_offsetX, _offsetY);
}

@end
