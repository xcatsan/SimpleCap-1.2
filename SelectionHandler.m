//
//  SelectionHandler.m
//  SimpleCap
//
//  Created by - on 08/03/16.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SelectionHandler.h"
#import "CaptureController.h"
#import "CaptureWindow.h"
#import "CaptureView.h"
#import "ThinButtonBar.h"
#import "ButtonTags.h"
#import "UserDefaults.h"
#import "DesktopWindow.h"
#import "CoordinateConverter.h"
#import "ImageFormat.h"
#import "TimerController.h"

// for [NSMenu popUpContextMenu:_capture_menu withEvent:event forView:nil];
// need it ?
#import "AppController.h"
//#import "SelectionHistory.h"

#define KNOB_WIDTH	15.0
#define MakeKnobRect(x,y) NSMakeRect(x-KNOB_WIDTH/2.0,y-KNOB_WIDTH/2.0,KNOB_WIDTH,KNOB_WIDTH)

enum KNOB_TYPE {
	KNOB_NON =-1,
	KNOB_TOP_LEFT=0 , KNOB_TOP_MIDDLE	, KNOB_TOP_RIGHT,
	KNOB_MIDDLE_LEFT					, KNOB_MIDDLE_RIGHT,
	KNOB_BOTTOM_LEFT, KNOB_BOTTOM_MIDDLE, KNOB_BOTTOM_RIGHT
};


enum SELECTION_STATE {
	STATE_CLEAR,
	STATE_RUBBERBAND,
	STATE_SELECTION
};

@implementation SelectionHandler

-(void)changeState:(int)state
{
	_state = state;
	CaptureView* view = [_capture_controller view];

	switch (_state) {
		case STATE_CLEAR:
			[_button_bar reset];
			[_button_bar2 reset];
			[_button_bar hide];
			[_button_bar2 hide];
			_display_knob = NO;
			_display_info = NO;
			_display_imageformat = NO;
			[_capture_controller enableMouseEventInWindow];
			break;
			
		case STATE_RUBBERBAND:
			[_button_bar reset];
			[_button_bar2 reset];
			[_button_bar show];
			if (_is_display_info) [_button_bar2 show];
			_display_knob = YES;
			_display_info = YES;
			_display_imageformat = YES;
			[view setNeedsDisplay:YES];
			[_capture_controller enableMouseEventInWindow];
			break;
			
		case STATE_SELECTION:
			[_button_bar hide];
			[_button_bar2 hide];
			_display_knob = YES;
			_display_info = YES;
			_display_imageformat = NO;
			[view setNeedsDisplay:YES];
			[_capture_controller disableMouseEventInWindow];
			break;

		default:
			break;
	}
}


//--------------------
// RubberBand medhots
//--------------------
#define INFORMATION_OFFSET_X 10.0
#define INFORMATION_OFFSET_Y 5.0
- (void)drawInformation
{
	NSString *info =
	[NSString stringWithFormat:@"%.0f x %.0f", 
	fabs(_rect.size.width), fabs(_rect.size.height)];
	NSMutableDictionary *stringAttributes = [NSMutableDictionary dictionary];
	
	[stringAttributes setObject:[NSFont boldSystemFontOfSize:12.0]
						 forKey: NSFontAttributeName];
	[stringAttributes setObject:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0]
						 forKey:NSForegroundColorAttributeName];
	/*
	[stringAttributes setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0]
						 forKey:NSStrokeColorAttributeName];
	[stringAttributes setObject:[NSNumber numberWithFloat: -1.5]
						 forKey:NSStrokeWidthAttributeName];
	*/
	NSPoint p = NSMakePoint(_rect.origin.x + INFORMATION_OFFSET_X, (_rect.origin.y + _rect.size.height - INFORMATION_OFFSET_Y - 20));
	
	[NSGraphicsContext saveGraphicsState];
	[_shadow set];
	[info drawAtPoint:p withAttributes: stringAttributes];
	[NSGraphicsContext restoreGraphicsState];
	
	NSSize size = [info sizeWithAttributes:stringAttributes];
	[_button_bar2 setDrawOffset:NSMakePoint(size.width, (20-size.height)/2+4)];
}


#define START_WIDTH		400
#define START_HEIGHT	250

- (void)resetRect
{
	NSScreen* screen = [NSScreen mainScreen];	// multi screen ok
	NSSize screen_size = [screen frame].size;
	_rect = NSMakeRect((screen_size.width - START_WIDTH)/2,
					   (screen_size.height - START_HEIGHT)/2,
					   START_WIDTH, START_HEIGHT);
	NSPoint bp = NSZeroPoint;
	bp = [[_capture_controller view] convertPoint:[[_capture_controller window] convertScreenToBase:NSMakePoint(0, screen_size.height)] fromView:nil];
	_rect.origin.x += bp.x;
	_rect.origin.y += bp.y;
}

- (void)setup
{
	[self resetRect];
	_shadow = [[NSShadow alloc] init];
	[_shadow setShadowOffset:NSMakeSize(2.0, -2.0)];
	[_shadow setShadowBlurRadius:0.5];
	[_shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
	
	_resize_unit = 5.0;
	_is_display_info = YES;

	_button_bar = [[ThinButtonBar alloc] initWithFrame:NSZeroRect];
	[_button_bar setPosition:SC_BUTTON_POSITION_RIGHT_TOP];

	[_button_bar addButtonWithImageResource:@"icon_cancel"
						 alterImageResource:@"icon_cancel2"
										tag:TAG_CANCEL
									tooltip:NSLocalizedString(@"CancelCapture", @"")
									  group:nil
						   isActOnMouseDown:NO];
	
	[_button_bar addButtonWithImageResource:@"icon_config"
						 alterImageResource:@"icon_config2"
										tag:TAG_CONFIG
									tooltip:NSLocalizedString(@"QuickConfig", @"")
									  group:nil
						   isActOnMouseDown:YES];
	
	[_button_bar addButtonWithImageResource:@"icon_timer"
						 alterImageResource:@"icon_timer2"
										tag:TAG_TIMER
									tooltip:NSLocalizedString(@"TimerSelection", @"")
									  group:nil
						   isActOnMouseDown:NO];

	[_button_bar addButtonWithImageResource:@"icon_record"
						 alterImageResource:@"icon_record2"
										tag:TAG_RECORD
									tooltip:NSLocalizedString(@"CaptureSelection", @"")
									  group:@"RECORD"
						   isActOnMouseDown:NO];

	[_button_bar addButtonWithImageResource:@"icon_copy"
						 alterImageResource:@"icon_copy2"
										tag:TAG_COPY
									tooltip:NSLocalizedString(@"CopySelection", @"")
									  group:@"RECORD"
						   isActOnMouseDown:NO];

	[_button_bar addButtonWithImageResource:@"icon_continuous"
						 alterImageResource:@"icon_continuous2"
										tag:TAG_CONTINUOUS
									tooltip:NSLocalizedString(@"ContinuouslyCapture", @"")
									  group:@"RECORD"
						   isActOnMouseDown:NO];
	
	[self drawInformation];	// dummy call (adjust offset)

	CaptureView *view = [_capture_controller view];
	[view addSubview:_button_bar];
	[view addSubview:_button_bar2];
	[_button_bar setDelegate:self];
	//[_button_bar2 setDelegate:self];
	
	_previous_state = STATE_RUBBERBAND;
	[self changeState:_previous_state];
	[_button_bar setButtonBarWithFrame:_rect];
	//[_button_bar2 setButtonBarWithFrame:_rect];

//	_selection_history = [[SelectionHistory selectionHistory] retain];
		
}

- (void)resetCursorRects
{
	CaptureView *view = [_capture_controller view];
	[view discardCursorRects];
	
	NSCursor* crosshairCursor       = [NSCursor crosshairCursor];
	NSCursor* resizeUpDownCursor    = [NSCursor resizeUpDownCursor];
	NSCursor* resizeLeftRightCursor = [NSCursor resizeLeftRightCursor];
	
	[view addCursorRect:MakeKnobRect(NSMinX(_rect), NSMinY(_rect))
				 cursor:crosshairCursor];
	[view addCursorRect:MakeKnobRect(NSMidX(_rect), NSMinY(_rect))
				 cursor:resizeUpDownCursor];
	[view addCursorRect:MakeKnobRect(NSMaxX(_rect), NSMinY(_rect))
				 cursor:crosshairCursor];
	[view addCursorRect:MakeKnobRect(NSMinX(_rect), NSMidY(_rect))
				 cursor:resizeLeftRightCursor];
	[view addCursorRect:MakeKnobRect(NSMaxX(_rect), NSMidY(_rect))
				 cursor:resizeLeftRightCursor];
	[view addCursorRect:MakeKnobRect(NSMinX(_rect), NSMaxY(_rect))
				 cursor:crosshairCursor];
	[view addCursorRect:MakeKnobRect(NSMidX(_rect), NSMaxY(_rect))
				 cursor:resizeUpDownCursor];
	[view addCursorRect:MakeKnobRect(NSMaxX(_rect), NSMaxY(_rect))
				 cursor:crosshairCursor];
}

- (NSRect)normalizeRect:(NSRect)rect
{
	NSRect rect2 = rect;
	
	if (rect.size.width < 0) {
		rect2.origin.x = rect.origin.x + rect.size.width;
		rect2.size.width = -rect.size.width;
	}
	if (rect.size.height < 0) {
		rect2.origin.y = rect.origin.y + rect.size.height;
		rect2.size.height = -rect.size.height;
	}
	return rect2;
}

- (void)drawKnobAtPoint:(NSPoint)p
{
	NSRect knob_box = MakeKnobRect(p.x,p.y);
	
	// box type
	/*
	[[NSColor whiteColor] set];
	NSRectFill(knob_box);   
	
	[[NSColor grayColor] set];
	NSFrameRectWithWidth(knob_box, 0.5);
*/
	
	// circle type
	NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:knob_box];
	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.2] set];
	[path fill];
	[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.5] set];
	[path stroke];
}

- (void)drawKnobs
{
	NSRect rect;
	rect.origin.x = floor(_rect.origin.x);
	rect.origin.y = floor(_rect.origin.y);
	rect.size.width = floor(_rect.size.width);
	rect.size.height = floor(_rect.size.height);
	[self drawKnobAtPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMidX(rect), NSMinY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMinX(rect), NSMidY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMaxX(rect), NSMidY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
	[self drawKnobAtPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
}

- (void)setDisplayInfo:(BOOL)flag
{
	_is_display_info = flag;
	if (_is_display_info) {
		[_button_bar2 show];
	} else {
		[_button_bar2 hide];
	}
	CaptureView* view = [_capture_controller view];
	[view setNeedsDisplayInRect:_rect];
	[view setNeedsDisplay:YES];
}

- (int)knobAtPoint:(NSPoint)p
{
	int knob_type = KNOB_NON;
	if (NSPointInRect(p, MakeKnobRect(NSMinX(_rect), NSMinY(_rect)))) {
		knob_type = KNOB_TOP_LEFT;
	} else if (NSPointInRect(p, MakeKnobRect(NSMidX(_rect), NSMinY(_rect)))) {
		knob_type = KNOB_TOP_MIDDLE;
	} else if (NSPointInRect(p, MakeKnobRect(NSMaxX(_rect), NSMinY(_rect)))) {
		knob_type = KNOB_TOP_RIGHT;
	} else if (NSPointInRect(p, MakeKnobRect(NSMinX(_rect), NSMidY(_rect)))) {
		knob_type = KNOB_MIDDLE_LEFT;
	} else if (NSPointInRect(p, MakeKnobRect(NSMaxX(_rect), NSMidY(_rect)))) {
		knob_type = KNOB_MIDDLE_RIGHT;
	} else if (NSPointInRect(p, MakeKnobRect(NSMinX(_rect), NSMaxY(_rect)))) {
		knob_type = KNOB_BOTTOM_LEFT;
	} else if (NSPointInRect(p, MakeKnobRect(NSMidX(_rect), NSMaxY(_rect)))) {
		knob_type = KNOB_BOTTOM_MIDDLE;
	} else if (NSPointInRect(p, MakeKnobRect(NSMaxX(_rect), NSMaxY(_rect)))) {
		knob_type = KNOB_BOTTOM_RIGHT;
	}
	return knob_type;
}

typedef struct _ResizeRule {
	CGFloat x, y, w, h;
} ResizeRule;

ResizeRule rules[8] = {
	{1, 1,-1,-1},	// TOP_LEFT
	{0, 1, 0,-1},	// TOP_MIDDLE
	{0, 1, 1,-1},	// TOP_RIGHT
	{1, 0,-1, 0},	// MIDDLE_LEFT
	{0, 0, 1, 0},	// MIDDLE_RIGHT
	{1, 0,-1, 1},	// BOTTOM_LEFT
	{0, 0, 0, 1},	// BOTTOM_MIDDLE
	{0, 0, 1, 1}	// BOTTOM_RIGHT
};


-(void)setRubberBandFrame:(NSRect)frame
{
	CaptureView* view = [_capture_controller view];
	NSUndoManager* undoManager = [view undoManager];
	if ([undoManager isUndoing] || [undoManager isRedoing]) {
		[[undoManager prepareWithInvocationTarget:self]
		 setRubberBandFrame:_rect];
	}
	
	_rect = frame;
//	[_delegate changedFrame:frame];
	[_button_bar setButtonBarWithFrame:frame];
	[_button_bar2 setButtonBarWithFrame:frame];
	[view setNeedsDisplay:YES];
}


//--------------------
// Handler methods
//--------------------
- (void)reset
{
	CaptureView* view = [_capture_controller view];
	NSUndoManager* undoManager = [view undoManager];
	[[undoManager prepareWithInvocationTarget:self]
	 setRubberBandFrame:_rect];
	[undoManager setActionName:NSLocalizedString(@"UndoMovedSelection", @"")];
	[self resetRect];
	[_button_bar setButtonBarWithFrame:_rect];
	[view setNeedsDisplay:YES];
}

- (BOOL)startWithObject:(id)object
{
	[self changeState:_previous_state];

	[self changedImageFormatTo:
	 [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue]];
//	[_button_bar resetGroup:@"COPY"];
	[_button_bar startFlasher];
	return YES;
}

- (void)tearDown
{
	_previous_state = _state;
	[self changeState:STATE_CLEAR];
}

//#define STRIP_WIDTH	22
#define STRIP_WIDTH	12
- (void)drawDragStrip:(NSRect)rect
{
	NSRect r1 = rect;
//	[[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.05] set];
	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.05] set];
	NSRectFill([self normalizeRect:r1]);

	NSRect r2 = rect;
	r2.size.width -= STRIP_WIDTH*2;
	r2.size.height -= STRIP_WIDTH*2;
	r2.origin.x += STRIP_WIDTH;
	r2.origin.y += STRIP_WIDTH;
	[[NSColor clearColor] set];
	NSRectFill([self normalizeRect:r2]);
}

#define IMAGEFORMAT_OFFSET_X 85.0
#define IMAGEFORMAT_OFFSET_Y 37.0
#define IMAGEFORMAT_MIN_WIDTH	145
#define IMAGEFORMAT_MIN_HEIGHT	75
- (void)drawImageFormatDisplay
{
	if (_rect.size.width >= IMAGEFORMAT_MIN_WIDTH &&
		_rect.size.height >= IMAGEFORMAT_MIN_HEIGHT) {
		NSPoint p = NSMakePoint(_rect.origin.x + _rect.size.width -  IMAGEFORMAT_OFFSET_X
								,_rect.origin.y + IMAGEFORMAT_OFFSET_Y);
		[ImageFormat drawImageFormatDisplayAt:p];
	}
}

- (void)drawRect:(NSRect)rect {

	NSBezierPath* path;
	NSGraphicsContext *gc;

	NSRect d_rect = _rect;
	d_rect.origin.y += 0.1;
	d_rect.size.height -= 0.2;
	d_rect.origin.x += 0.1;
	d_rect.size.width -= 0.2;
	
	switch (_state) {
		case STATE_CLEAR:
			break;
			
		case STATE_RUBBERBAND:
//			[self drawBackground:rect];
//			[[NSColor clearColor] set];
			[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.05] set];
			NSRectFill([self normalizeRect:d_rect]);
//			[self drawDragStrip:_rect];
			
			path = [NSBezierPath bezierPath];
			[path appendBezierPathWithRect:d_rect];
			[path setLineWidth:0.5];
			
			gc = [NSGraphicsContext currentContext];
			[gc saveGraphicsState];
			[gc setShouldAntialias:NO];
			
			[[NSColor grayColor] set];
			[path stroke];

			[gc restoreGraphicsState];
			
			if (_display_knob) {
				[self drawKnobs];
			}	
			
			if (_display_info && _is_display_info) {
				[self drawInformation];
			}
			if (_display_imageformat) {
				[self drawImageFormatDisplay];
			}
						
			break;

		case STATE_SELECTION:
			[self drawDragStrip:d_rect];
			[self drawSelectedBoxRect:_rect Counter:_animation_counter];
			if (_display_knob) {
				[self drawKnobs];
			}	
			
			break;
	}
}


#define SC_MARGIN_ORIGIN_Y	0.0

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint pp, cp;
	CaptureView *view = [_capture_controller view];
	CaptureWindow *window = [_capture_controller window];

	cp = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	int knob_type;
	
	switch (_state) {
		case STATE_CLEAR:
			[[NSCursor crosshairCursor] push];
			while ([theEvent type] != NSLeftMouseUp) {
				theEvent = [window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
				NSPoint cp2 = [view convertPoint:[theEvent locationInWindow] fromView:nil];
				if (fabs(cp2.x - cp.x) > KNOB_WIDTH || fabs(cp2.y - cp.y) > KNOB_WIDTH) {
					knob_type = 7;	// BOTTOM_RIGHT;
					_rect = NSMakeRect(cp.x, cp.y, 0, 0);
					[_button_bar show];
					if (_is_display_info) [_button_bar2 show];
					_display_imageformat = YES;

					break;
				}
				if ([theEvent type] == NSLeftMouseUp) {
					[NSCursor pop];
					return;
				}
			}
			break;
			
		case STATE_RUBBERBAND:
			knob_type = [self knobAtPoint:cp];
			break;
			
		case STATE_SELECTION:
			// 2008-11-03
			knob_type = [self knobAtPoint:cp];
			break;
			/* 2008-11-03
			return;
			// ** not reached **
			*/
			
		default:
			break;
	}
	CGFloat dx, dy;
	NSUndoManager* undoManager = [view undoManager];

	if (knob_type != KNOB_NON) {
		//
		// handling a knob
		//
		pp = cp;
		int resize_by_similar = [theEvent modifierFlags] & NSShiftKeyMask;
		int resize_by_unit    = [theEvent modifierFlags] & NSCommandKeyMask;
		
		CGFloat psin, pcos;
		
		if (_state == STATE_CLEAR) {
			_state = STATE_RUBBERBAND;
		} else {
			[[undoManager prepareWithInvocationTarget:self]
			 setRubberBandFrame:_rect];
			[undoManager setActionName:NSLocalizedString(@"UndoResizeSelection", @"")];
		}
		
		[_button_bar hide];
		[_button_bar2 hide];
		_display_imageformat = NO;

		while ([theEvent type] != NSLeftMouseUp) {
			
			theEvent = [window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
			cp = [view convertPoint:[theEvent locationInWindow] fromView:nil];
			dx = cp.x - pp.x;
			dy = cp.y - pp.y;
			
			resize_by_unit    = [theEvent modifierFlags] & NSCommandKeyMask;
			resize_by_similar = [theEvent modifierFlags] & NSShiftKeyMask;
			
			if (resize_by_similar) {
				CGFloat h = _rect.size.height;
				CGFloat w = _rect.size.width;
				
				if (resize_by_unit) {
					CGFloat dh = fmod(h, _resize_unit);
					CGFloat dw = fmod(w, _resize_unit);
					if (dh > _resize_unit/2.0) {
						h = h - dh + _resize_unit;
					} else {
						h = h - dh;
					}
					if (dw > _resize_unit/2.0) {
						w = w - dw + _resize_unit;
					} else {
						w = w - dw;
					}
				}
				
				CGFloat degree = atan2(h, w);
				pcos = cos(degree);
				psin = sin(degree);
			}
			
			ResizeRule rule = rules[knob_type];
			if (resize_by_similar) {
				BOOL resized = NO;
				CGFloat rule_s = rule.w * rule.h;
				CGFloat sx, sy;
				if (rule_s > 0) {
					if (-dx < dy) {
						sx = +1;
						sy = +1;
					} else {
						sx = -1;
						sy = -1;
					}
					resized = YES;
					
				} else if (rule_s < 0) {
					if (dx < dy) {
						sx = -1;
						sy = +1;
					} else {
						sx = +1;
						sy = -1;
					}
					resized = YES;
				}
				if (resized) {
					CGFloat dl = sqrt(dx*dx + dy*dy);
					dx = sx * dl * pcos;
					dy = sy * dl * psin;
				}
			}
			
			CGFloat mx, my;
			
			if (resize_by_unit) {
				if (resize_by_similar) {
					if (fabs(dx) >= _resize_unit || fabs(dy) >= _resize_unit) {
						mx = fmod(dx, _resize_unit);
						my = fmod(dy, _resize_unit);
						CGFloat mm = fmax((dx - mx) / _resize_unit, (dy - my) / _resize_unit);
						dx = mm * _resize_unit;
						dy = mm * _resize_unit;
						pp.x = cp.x - mx;
						pp.y = cp.y - my;
					} else {
						dx = 0.0;
						dy = 0.0;
					}
				} else {
					if (fabs(dx) >= _resize_unit) {
						mx = fmod(dx, _resize_unit);
						dx = dx - mx;
						pp.x = cp.x - mx;
						
					} else {
						dx = 0.0;
					}
					if (fabs(dy) >= _resize_unit) {
						my = fmod(dy, _resize_unit);
						dy = dy - my;
						pp.y = cp.y - my;
						
					} else {
						dy = 0.0;
					}
				}
			} else {
				pp.x = cp.x;
				pp.y = cp.y;
			}
			
			/*
			 _rect.origin.x    += dx * rule.x;
			 _rect.origin.y    += dy * rule.y;
			 _rect.size.width  += dx * rule.w;
			 _rect.size.height += dy * rule.h;
			 */
			CGFloat nx = _rect.origin.x    + dx * rule.x;
			CGFloat ny = _rect.origin.y    + dy * rule.y;
			CGFloat nw = _rect.size.width  + dx * rule.w;
			CGFloat nh = _rect.size.height + dy * rule.h;
			NSRect bounds = [view bounds];
			if (nx < 0) {
				nw = _rect.size.width + _rect.origin.x;
				nx = 0.0;
			} else if (nx + nw > bounds.size.width) {
				nw = bounds.size.width - nx - SC_MARGIN_ORIGIN_Y;
			} else if (nx + nw < 0) {
				nw = -_rect.origin.x;
			}
			if (ny < 0) {
				nh = _rect.size.height + _rect.origin.y;
				ny = SC_MARGIN_ORIGIN_Y;
			} else if (ny + nh > bounds.size.height) {
				nh = bounds.size.height - ny;
			} else if (ny + nh < 0) {
				nh = -_rect.origin.y + SC_MARGIN_ORIGIN_Y;
			}
			
			_rect = NSMakeRect(nx, ny, nw, nh);
			
			if (resize_by_unit) {
				mx = fmod(_rect.size.width, _resize_unit);
				my = fmod(_rect.size.height, _resize_unit);
				
				if (mx && fabs(dx) > 0.0) {
					if (rule.x > 0) {
						if (dx > 0) {
							_rect.origin.x   += -(_resize_unit - mx) * rule.x;
							_rect.size.width += -(_resize_unit - mx) * rule.w;
						} else if (dx < 0) {
							_rect.origin.x   += mx * rule.x;
							_rect.size.width += mx * rule.w;
						}
					} else {
						if (dx > 0) {
							_rect.origin.x   += -mx * rule.x;
							_rect.size.width += -mx * rule.w;
						} else if (dx < 0) {
							_rect.origin.x   += (_resize_unit - mx) * rule.x;
							_rect.size.width += (_resize_unit - mx) * rule.w;
						}
					}
				}
				if (my && fabs(dy) > 0.0) {
					if (rule.y > 0) {
						if (dy > 0) {
							_rect.origin.y    += -(_resize_unit - my) * rule.y;
							_rect.size.height += -(_resize_unit - my) * rule.h;
						} else if (dy < 0) {
							_rect.origin.y    += my * rule.y;
							_rect.size.height += my * rule.h;
						}
					} else {
						if (dy > 0) {
							_rect.origin.y    += -my * rule.y;
							_rect.size.height += -my * rule.h;
						} else if (dy < 0) {
							_rect.origin.y    += (_resize_unit - my) * rule.y;
							_rect.size.height += (_resize_unit - my) * rule.h;
						}
					}
				}
			}
			
//			[_delegate changedFrame:[self normalizeRect:_rect]];
			[view setNeedsDisplay:YES];
		}
		if (_state == STATE_RUBBERBAND) {
			[_button_bar show];
			if (_is_display_info) [_button_bar2 show];
			_display_imageformat = YES;
		}
		_rect = [self normalizeRect:_rect];
		[_button_bar setButtonBarWithFrame:_rect];
		[_button_bar2 setButtonBarWithFrame:_rect];
		[self resetCursorRects];
		
	} else if (NSPointInRect(cp, _rect)) {
		
		// Moving rectangle
		
		[[undoManager prepareWithInvocationTarget:self]
		 setRubberBandFrame:_rect];
		[undoManager setActionName:NSLocalizedString(@"UndoMovedSelection", @"")];
		[_button_bar hide];
		[_button_bar2 hide];
		_display_info = NO;
		_display_knob = NO;
		_display_imageformat = NO;
		[view setNeedsDisplay:YES];		// temporary for information display

		dx = _rect.origin.x - cp.x;
		dy = _rect.origin.y - cp.y;
		NSPoint p_cp = cp; 
		int constrain_mode = 0;
		while ([theEvent type] != NSLeftMouseUp) {
			theEvent = [window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
			cp = [view convertPoint:[theEvent locationInWindow] fromView:nil];
			BOOL is_shiftkey = ([theEvent modifierFlags] & NSShiftKeyMask) ? YES : NO;

			// constrain rule (1)
			if (is_shiftkey) {
				CGFloat dcpx = fabs(cp.x - p_cp.x);
				CGFloat dcpy = fabs(cp.y - p_cp.y);
				if (constrain_mode == 0) {
					constrain_mode = (dcpx > dcpy) ? 1 : 2;
				} else {
					if (dcpx == 0 && dcpy > 5.0) {
						constrain_mode =2;
					} else if (dcpx > 5.0 && dcpy == 0) {
						constrain_mode =1;
					}
				}
				switch (constrain_mode) {
					case 1: // horizontal moving
						_rect.origin.x = cp.x + dx;
						break;
					case 2: // vertical moving
						_rect.origin.y = cp.y + dy;
						break;
					default:
						break;
				}
			} else {
				_rect.origin.x = cp.x + dx;
				_rect.origin.y = cp.y + dy;
			}
			
			// constrain rule (2)
			_rect.origin.x = fmax(_rect.origin.x, 0.0);
			_rect.origin.y = fmax(_rect.origin.y, SC_MARGIN_ORIGIN_Y);
			NSRect bounds = [view bounds];
			if (_rect.origin.x + _rect.size.width > bounds.size.width) {
				_rect.origin.x = bounds.size.width - _rect.size.width - SC_MARGIN_ORIGIN_Y;
			}
			if (_rect.origin.y + _rect.size.height > bounds.size.height) {
				_rect.origin.y = bounds.size.height - _rect.size.height;
			}
			
//			[_delegate changedFrame:[self normalizeRect:_rect]];
			[view setNeedsDisplayInRect:_rect];
			[view setNeedsDisplay:YES];
			p_cp = cp;
		}
		[_button_bar setButtonBarWithFrame:[self normalizeRect:_rect]];
		[_button_bar2 setButtonBarWithFrame:[self normalizeRect:_rect]];
		_display_knob = YES;
		_display_info = YES;
		_display_imageformat = YES;
		if (_state == STATE_RUBBERBAND) {
			[_button_bar show];
//			[_button_bar startFlasher];
			if (_is_display_info) [_button_bar2 show];
			_display_imageformat = YES;

		}
		[self resetCursorRects];
	}

}

- (void)mouseMoved:(NSEvent *)theEvent
{
}

- (void) dealloc
{
	[_shadow release];
	[_button_bar release];
	[_button_bar2 release];
//	[_selection_history release];
	[super dealloc];
}


#define WHITE_FRAME_WIDTH	5.0
#define ROUND_RECT_RADIUS	12.0
#define ROUND_RADIUS_INNER	2.0
#define SHADOW_WIDTH		3.0
#define	SHADOW_BLUR_RADIUS	30.0
#define SHADOW_PADDING		(SHADOW_WIDTH+SHADOW_BLUR_RADIUS*0.5)
#define FRAME_WIDTH			0.1
#define SHADOW_ALPHA		0.75

- (CGImageRef)capture
{
	_mouse_pointer_offset = NSZeroSize;

	BOOL is_shadow = [[UserDefaults valueForKey:UDKEY_SELECTION_SHADOW] boolValue];
	BOOL is_roundrect = [[UserDefaults valueForKey:UDKEY_SELECTION_ROUND_RECT] boolValue];
	BOOL is_white_frame = [[UserDefaults valueForKey:UDKEY_SELECTION_WHITE_FRAME] boolValue];
	BOOL is_exclude_desktop_icons = [[UserDefaults valueForKey:UDKEY_SELECTION_EXCLUDE_ICONS] boolValue];
	
	CGWindowImageOption option = kCGWindowListOptionOnScreenBelowWindow;
	if (is_exclude_desktop_icons) {
		option |= kCGWindowListExcludeDesktopElements;
	}
	NSRect s_rect = _rect;
	s_rect.origin = [CoordinateConverter convertFromLocalToCGWindowPoint:_rect.origin];
	CGImageRef cgimage = CGWindowListCreateImage(NSRectToCGRect(s_rect), option,
												 [_capture_controller windowID],
												 kCGWindowImageDefault);

	if (!is_shadow && !is_roundrect && !is_white_frame && !is_exclude_desktop_icons) {
		return cgimage;
		// *not reached*
	}
	
	// change to NSImage
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithCGImage:cgimage] autorelease];
	NSImage* src_image = [[[NSImage alloc] init] autorelease];
	[src_image addRepresentation:bitmap];
	
	// draw desktop
	if (is_exclude_desktop_icons) {
		NSArray* desktop_window_list = [[DesktopWindow sharedDesktopWindow] CGWindowIDlist];
		CGWindowID *windowIDs = calloc([desktop_window_list count], sizeof(CGWindowID));
		int widx = 0;
		for (NSNumber* num in desktop_window_list) {
			windowIDs[widx++] = [num unsignedIntValue];
		}
		CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, widx, NULL);
		CGImageRef cgimage_desktop = CGWindowListCreateImageFromArray(NSRectToCGRect(s_rect), windowIDsArray, kCGWindowImageDefault);
		NSBitmapImageRep *bitmap_desktop = [[[NSBitmapImageRep alloc] initWithCGImage:cgimage_desktop] autorelease];
		NSImage* image_desktop = [[[NSImage alloc] init] autorelease];
		[image_desktop addRepresentation:bitmap_desktop];
		[image_desktop lockFocus];
		[src_image drawAtPoint:NSZeroPoint
					  fromRect:NSZeroRect
					 operation:NSCompositeSourceOver fraction:1.0];
		[image_desktop unlockFocus];
		src_image = image_desktop;
	}

	// setup
	NSSize size = [src_image size];
	NSRect src_image_rect = NSMakeRect(0,
									   0,
									   size.width,
									   size.height);
	NSRect frame_rect = src_image_rect;
	NSRect output_image_rect = src_image_rect;

	if (is_white_frame) {
		src_image_rect.origin.x += WHITE_FRAME_WIDTH;
		src_image_rect.origin.y += WHITE_FRAME_WIDTH;

		frame_rect.size.width += WHITE_FRAME_WIDTH*2;
		frame_rect.size.height += WHITE_FRAME_WIDTH*2;

		output_image_rect.size.width += WHITE_FRAME_WIDTH*2;
		output_image_rect.size.height += WHITE_FRAME_WIDTH*2;
		
		_mouse_pointer_offset.width += WHITE_FRAME_WIDTH;
		_mouse_pointer_offset.height += WHITE_FRAME_WIDTH;
	}
	if (is_shadow) {
		src_image_rect.origin.x += SHADOW_PADDING;
		src_image_rect.origin.y += SHADOW_PADDING;
		
		frame_rect.origin.x += SHADOW_PADDING;
		frame_rect.origin.y += SHADOW_PADDING;

		output_image_rect.size.width += SHADOW_PADDING*2;
		output_image_rect.size.height += SHADOW_PADDING*2;

		_mouse_pointer_offset.width += SHADOW_PADDING;
		_mouse_pointer_offset.height += SHADOW_PADDING;
	}

	NSImage *output_image = [[[NSImage alloc] initWithSize:output_image_rect.size] autorelease];
	
	NSRect inner_rect = src_image_rect;

	NSBezierPath* src_image_path;
	NSBezierPath* frame_path;
	NSBezierPath* inner_path;
	if (is_roundrect) {
		src_image_path = [NSBezierPath bezierPathWithRoundedRect:src_image_rect
														 xRadius:ROUND_RECT_RADIUS-ROUND_RADIUS_INNER
														 yRadius:ROUND_RECT_RADIUS-ROUND_RADIUS_INNER];
		
		frame_path = [NSBezierPath bezierPathWithRoundedRect:frame_rect
													 xRadius:ROUND_RECT_RADIUS
													 yRadius:ROUND_RECT_RADIUS];
		
		inner_path = [NSBezierPath bezierPathWithRoundedRect:inner_rect
													 xRadius:ROUND_RECT_RADIUS-ROUND_RADIUS_INNER
													 yRadius:ROUND_RECT_RADIUS-ROUND_RADIUS_INNER];
	} else {
		frame_path = [NSBezierPath bezierPathWithRect:frame_rect];
		inner_path = [NSBezierPath bezierPathWithRect:inner_rect];
	}
	// start draw
	[output_image lockFocus];
	[NSGraphicsContext saveGraphicsState];
	
	// Selection Shadow
	if (is_shadow) {
		NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(SHADOW_WIDTH, -SHADOW_WIDTH)];
		[shadow setShadowBlurRadius:SHADOW_BLUR_RADIUS];
		[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:SHADOW_ALPHA]];
		[shadow set];
	}
	
	// White Frame
	[[NSColor whiteColor] set];
	[frame_path fill];
	
	[NSGraphicsContext restoreGraphicsState];

	// Compsite Image
	if (is_roundrect) {
		[src_image_path setClip];
	}
	[src_image compositeToPoint:src_image_rect.origin operation:NSCompositeSourceOver];

	
	if (is_white_frame) {
		NSGraphicsContext* gc = [NSGraphicsContext currentContext];
		NSColor *frame_color;
		CGFloat frame_width;
		if (is_roundrect) {
			frame_color = [NSColor colorWithDeviceRed:0.25 green:0.25 blue:0.25 alpha:1.0];
			frame_width = FRAME_WIDTH*5.0;
		} else {
			[gc setShouldAntialias:NO];
			frame_color = [NSColor colorWithDeviceRed:0.75 green:0.75 blue:0.75 alpha:1.0];
			frame_width = FRAME_WIDTH;
		}
		[frame_color set];
		[inner_path setLineWidth:frame_width];
		[inner_path stroke];
		[gc setShouldAntialias:YES];
	}

	// end draw
	[output_image unlockFocus];

	// restore to CGImage
	NSBitmapImageRep *out_bitmap = [NSBitmapImageRep imageRepWithData:[output_image TIFFRepresentation]];

	CGImageRef out_image = [out_bitmap CGImage];
	CGImageRelease(cgimage);
	CGImageRetain(out_image);
	
	// Good job!
	return out_image;
}

//------------------------
// Menu delegates -->
//------------------------
/*
-(NSArray*)menuWithTag:(NSNumber*)tag
{
	NSArray* array;
	switch ([tag intValue]) {
		case TAG_SELECTION_HISTORY:
			array = [_selection_history menuList];
			break;

		default:
			array = [NSArray array];
			break;
	}
	return array;
}
*/
-(void)setSize:(NSSize)size
{
	NSRect frame = _rect;
	frame.size = size;
	CaptureView* view = [_capture_controller view];
	NSUndoManager* undoManager = [view undoManager];
	[[undoManager prepareWithInvocationTarget:self]
	 setRubberBandFrame:_rect];
	[undoManager setActionName:NSLocalizedString(@"UndoResizeSelection", @"")];
	[self setRubberBandFrame:frame];
}

/*
-(void)selectMenuAtTag:(NSNumber*)tag atIndex:(NSNumber*)index
{
	NSSize size;
	switch ([tag intValue]) {
		case TAG_SELECTION_HISTORY:
			 size = [_selection_history sizeAtIndex:[index intValue]];
			[_selection_history setSize:size];
			[self setSize:size];
			break;

		default:
			break;
	}
}
*/
//------------------------
// <-- Menu delegates
//------------------------

-(void)clickedAtTag:(NSNumber*)tag event:(NSEvent*)event
{
	switch ([tag intValue]) {
		case TAG_CANCEL:
			[_capture_controller cancel];
			break;
			
		case TAG_TIMER:
			_animation_counter = 0;
			[_capture_controller startTimerOnClient:self
											  title:NSLocalizedString(@"TimerTitleSelection", @"")
											  image:nil];
			[self changeState:STATE_SELECTION];
			break;

		case TAG_COPY:
			[_capture_controller copyImage:[self capture] imageFrame:_rect];
			[_capture_controller exit];
			break;

		case TAG_COPY_CONTINUOUS:
			[_capture_controller copyImage:[self capture] imageFrame:_rect];
			break;
			
		case TAG_RECORD:
			[_capture_controller setContinouslyFlag:NO];
			[_capture_controller saveImage:[self capture] imageFrame:_rect];
//			[_selection_history setSize:_rect.size];
			[_capture_controller exit];
			break;

		case TAG_CONTINUOUS:
			[_capture_controller setContinouslyFlag:YES];
			[_capture_controller saveImage:[self capture] imageFrame:_rect];
//			[_selection_history setSize:_rect.size];
			break;

		case TAG_CONFIG:
			[_capture_controller openSelectionConfigMenuWithView:nil event:event];
			[[_capture_controller view] setNeedsDisplay:YES];
			break;

		default:
			[_capture_controller cancel];
			break;
	}
}

- (NSInteger)windowLevel
{
	return [super defaultWindowLevel];
}



//
// <TimerClient>
//
- (void)timerStarted:(TimerController*)controller
{
}

- (void)timerCounted:(TimerController*)controller
{
	_animation_counter++;
	CaptureView* view = [_capture_controller view];
	[view setNeedsDisplayInRect:_rect];
	[view setNeedsDisplay:YES];
}

- (void)timerFinished:(TimerController*)controller
{
	if ([controller isCopy]) {
		[self changeState:STATE_RUBBERBAND];
		[_capture_controller copyImage:[self capture] withMouseCursorInRect:_rect offset:_mouse_pointer_offset imageFrame:_rect];
		[_capture_controller exit];

	} else if ([controller isContinous]) {
		[_capture_controller setContinouslyFlag:YES];
		[_capture_controller saveImage:[self capture] withMouseCursorInRect:_rect offset:_mouse_pointer_offset imageFrame:_rect];
		[controller start];

	} else {
		// NORMAL
		[self changeState:STATE_RUBBERBAND];
		[_capture_controller saveImage:[self capture] withMouseCursorInRect:_rect offset:_mouse_pointer_offset imageFrame:_rect];
		[_capture_controller openViewerWithLastfile];
		[_capture_controller exit];
	}

}

- (void)timerCanceled:(TimerController*)controller
{
	[self changeState:STATE_RUBBERBAND];
//	[_capture_controller exit];
}

- (void)timerPaused:(TimerController*)controller
{
}

- (void)timerRestarted:(TimerController*)controller
{
}

- (void)openConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	[_capture_controller openSelectionConfigMenuWithView:view event:event];
}

// context menu
- (void)selectSize:(NSMenuItem*)item
{
	NSString* key_width = nil;
	NSString* key_height = nil;
	switch ([item tag]) {
		case 1:
			key_width = UDKEY_SELECTION_WIDTH1;
			key_height = UDKEY_SELECTION_HEIGHT1;
			break;
		case 2:
			key_width = UDKEY_SELECTION_WIDTH2;
			key_height = UDKEY_SELECTION_HEIGHT2;
			break;
		case 3:
			key_width = UDKEY_SELECTION_WIDTH3;
			key_height = UDKEY_SELECTION_HEIGHT3;
			break;
		case 4:
			key_width = UDKEY_SELECTION_WIDTH4;
			key_height = UDKEY_SELECTION_HEIGHT4;
			break;
		case 5:
			key_width = UDKEY_SELECTION_WIDTH5;
			key_height = UDKEY_SELECTION_HEIGHT5;
			break;
	}
	
	if (key_width && key_height) {
		NSSize size = NSMakeSize([[UserDefaults valueForKey:key_width] floatValue],
								 [[UserDefaults valueForKey:key_height] floatValue]);
		[self setSize:size];
	}
}

- (NSString*)sizeTitleWithNameKey:(NSString*)name_key widthKey:(NSString*)width_key heightKey:(NSString*)height_key
{
	NSString* title = [NSString stringWithFormat:@"(%@ x %@) %@",
					   [UserDefaults valueForKey:width_key],
					   [UserDefaults valueForKey:height_key],
					   [UserDefaults valueForKey:name_key]];
	return title;
}

/*
- (void)selectMenuItem:(NSMenuItem *)menu_item
{
	[self performSelector:@selector(selectMenuAtTag:atIndex:)
					withObject:[menu_item representedObject]
					withObject:[NSNumber numberWithInt:[menu_item tag]]];
}
*/
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [super menuForEvent:theEvent];
	
	/*
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
	NSMenuItem* item;
	NSString* title;

	// (0) pereferences
	title = NSLocalizedString(@"MenuOpenPreferences", @"");
	item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(openPereferecesWindow:)
								keyEquivalent:@""] autorelease];
	[item setTarget:[_capture_controller appController]];
	[item setRepresentedObject:[NSNumber numberWithInt:2]];		// 2->Preference Tab:2 (selection option)
	[menu addItem:item];
	[menu addItem:[NSMenuItem separatorItem]];

	
	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME1
							  widthKey:UDKEY_SELECTION_WIDTH1
							 heightKey:UDKEY_SELECTION_HEIGHT1];
	item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(selectSize:)
								keyEquivalent:@""] autorelease];
	[item setTag:1];
	[item setTarget:self];
	[menu addItem:item];

	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME2
							  widthKey:UDKEY_SELECTION_WIDTH2
							 heightKey:UDKEY_SELECTION_HEIGHT2];
	item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(selectSize:)
								keyEquivalent:@""] autorelease];
	[item setTag:2];
	[item setTarget:self];
	[menu addItem:item];

	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME3
							  widthKey:UDKEY_SELECTION_WIDTH3
							 heightKey:UDKEY_SELECTION_HEIGHT3];
	item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(selectSize:)
								keyEquivalent:@""] autorelease];
	[item setTag:3];
	[item setTarget:self];
	[menu addItem:item];

	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME4
							  widthKey:UDKEY_SELECTION_WIDTH4
							 heightKey:UDKEY_SELECTION_HEIGHT4];
	item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(selectSize:)
								keyEquivalent:@""] autorelease];
	[item setTag:4];
	[item setTarget:self];
	[menu addItem:item];

	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME5
							  widthKey:UDKEY_SELECTION_WIDTH5
							 heightKey:UDKEY_SELECTION_HEIGHT5];
	item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(selectSize:)
								keyEquivalent:@""] autorelease];
	[item setTag:5];
	[item setTarget:self];
	[menu addItem:item];
	
	// (2)sepearator
	[menu addItem:[NSMenuItem separatorItem]];
	
	// (3) history
	NSInteger idx = 0;
	NSNumber* tag_number = [NSNumber numberWithInt:TAG_SELECTION_HISTORY];
	for (NSString*title in [_selection_history menuList]) {
		item = [[[NSMenuItem alloc] initWithTitle:title
										   action:@selector(selectMenuItem:)
									keyEquivalent:@""] autorelease];
		[item setTag:idx++];
		[item setTarget:self];
		[item setRepresentedObject:tag_number];
		[menu addItem:item];
	}
	if (idx == 0) {
		item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SelectionHistoryNone", @"")
										   action:nil
									keyEquivalent:@""] autorelease];
		[menu addItem:item];
	}
	 return menu;
	*/
	
}

- (void)setupQuickConfigMenu:(NSMenu*)menu
{
	//	[super setupQuickConfigMenu:menu];
	NSMenuItem* item;
	NSString* title;
	
	item = [menu itemWithTag:1];
	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME1
							  widthKey:UDKEY_SELECTION_WIDTH1
							 heightKey:UDKEY_SELECTION_HEIGHT1];
	[item setTitle:title];
	[item setAction:@selector(selectSize:)];
	[item setTarget:self];

	item = [menu itemWithTag:2];
	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME2
							  widthKey:UDKEY_SELECTION_WIDTH2
							 heightKey:UDKEY_SELECTION_HEIGHT2];
	[item setTitle:title];
	[item setAction:@selector(selectSize:)];
	[item setTarget:self];

	item = [menu itemWithTag:3];
	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME3
							  widthKey:UDKEY_SELECTION_WIDTH3
							 heightKey:UDKEY_SELECTION_HEIGHT3];
	[item setTitle:title];
	[item setAction:@selector(selectSize:)];
	[item setTarget:self];

	item = [menu itemWithTag:4];
	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME4
							  widthKey:UDKEY_SELECTION_WIDTH4
							 heightKey:UDKEY_SELECTION_HEIGHT4];
	[item setTitle:title];
	[item setAction:@selector(selectSize:)];
	[item setTarget:self];

	item = [menu itemWithTag:5];
	title = [self sizeTitleWithNameKey:UDKEY_SELECTION_NAME5
							  widthKey:UDKEY_SELECTION_WIDTH5
							 heightKey:UDKEY_SELECTION_HEIGHT5];
	[item setTitle:title];
	[item setAction:@selector(selectSize:)];
	[item setTarget:self];

}	
	
	

- (void)keyDown:(NSEvent *)theEvent
{
	[super keyDown:theEvent];
	
	int shift_flag = [theEvent modifierFlags] & NSShiftKeyMask;
	int command_flag = [theEvent modifierFlags] & NSCommandKeyMask;
	int option_flag = [theEvent modifierFlags] & NSAlternateKeyMask;
	
	NSRect rect = _rect;
	BOOL is_modified = NO;
	NSString *action_name;
	CGFloat delta;

	if (option_flag) {
		delta = 10;
	} else {
		delta = 1;
	}
	
	switch ([theEvent keyCode]) {
		case 6:
			// command + z
			if (command_flag) {
				CaptureView* view = [_capture_controller view];
				NSUndoManager* undoManager = [view undoManager];
				
				if (shift_flag) {
					[undoManager redo];
				} else {
					[undoManager undo];
				}
			}
			break;
			
		case 8:
			// command + c
			if (command_flag) {
				[self clickedAtTag:[NSNumber numberWithInt:TAG_COPY] event:theEvent];
			}
			break;
			
		case 17:
			// command + t
			if (command_flag) {
				[self clickedAtTag:[NSNumber numberWithInt:TAG_TIMER] event:theEvent];
			}
			break;
			
		case 36:
			// return key
		case 49:
			// space key
			//			[self setDisplayInfo:!_is_display_info];
			if (command_flag) {
				[self clickedAtTag:[NSNumber numberWithInt:TAG_COPY] event:theEvent];
			} else if (option_flag) {
				[self clickedAtTag:[NSNumber numberWithInt:TAG_CONTINUOUS] event:theEvent];
			} else {
				[self clickedAtTag:[NSNumber numberWithInt:TAG_RECORD] event:theEvent];
			}
			break;
			
		case 123:
			// left
			if (shift_flag) {
				rect.size.width -= delta;
				action_name = NSLocalizedString(@"UndoResizeSelection", @"");
			} else {
				rect.origin.x -= delta;
				action_name = NSLocalizedString(@"UndoMovedLeft", @"");
			}
			_display_knob = NO;
			is_modified = YES;
			break;
		case 124:
			// right
			if (shift_flag) {
				rect.size.width += delta;
				action_name = NSLocalizedString(@"UndoResizeSelection", @"");
			} else {
				rect.origin.x += delta;
				action_name = NSLocalizedString(@"UndoMovedRight", @"");
			}
			_display_knob = NO;
			is_modified = YES;
			break;
		case 125:
			// down
			if (shift_flag) {
				rect.size.height += delta;
				action_name = NSLocalizedString(@"UndoResizeSelection", @"");
			} else {
				rect.origin.y += delta;
				action_name = NSLocalizedString(@"UndoMoved", @"");
			}
			is_modified = YES;
			_display_knob = NO;
			break;
		case 126:
			// up
			if (shift_flag) {
				rect.size.height -= delta;
				action_name = NSLocalizedString(@"UndoResizeSelection", @"");
			} else {
				rect.origin.y -= delta;
				action_name = @"Moved up";
			}
			is_modified = YES;
			_display_knob = NO;
			break;
		default:
			break;
	}
	if (is_modified) {
		CaptureView* view = [_capture_controller view];
		NSUndoManager* undoManager = [view undoManager];
		[[undoManager prepareWithInvocationTarget:self]
		 setRubberBandFrame:_rect];
		[undoManager setActionName:action_name];
		[self setRubberBandFrame:rect];
	}
	
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	NSUInteger modifierFlags = [theEvent modifierFlags];
	
	[_button_bar resetGroup:@"RECORD"];
	if (modifierFlags & NSCommandKeyMask) {
		[_button_bar switchGroup:@"RECORD"];
	} else if (modifierFlags & NSAlternateKeyMask) {
		[_button_bar switchGroup:@"RECORD"];
		[_button_bar switchGroup:@"RECORD"];
	} else 	if ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_CLIPBOARD) {
		[_button_bar switchGroup:@"RECORD"];
	}
	[_button_bar setNeedsDisplay:YES];
}

- (void)changedImageFormatTo:(int)image_format
{
	[_button_bar resetGroup:@"RECORD"];
	if (image_format == IMAGEFORMAT_CLIPBOARD) {
		[_button_bar switchGroup:@"RECORD"];
	}
	[_button_bar setNeedsDisplay:YES];
}

@end
