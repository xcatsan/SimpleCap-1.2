//
//  WindowHandler.m
//  SimpleCap
//
//  Created by - on 08/06/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "WindowHandler.h"
#import "CaptureController.h"
#import "TimerController.h"
#import "ThinButtonBar.h"
#import "ButtonTags.h"
#import	"Window.h"
#import "Transition.h"
// for [NSMenu popUpContextMenu:_capture_menu withEvent:event forView:nil];
// need it ?
#import "AppController.h"
#import "ImageFormat.h"
#import "UserDefaults.h"

enum WINDOW_STATE {
	STATE_HIDE,
	STATE_NOSELECTED,
	STATE_SELECTED,
	STATE_TIMER,
	STATE_TRANSITION
};

@implementation WindowHandler

-(void)changeState:(int)state
{
	_state = state;
	CaptureView* view = [_capture_controller view];
	
	switch (_state) {
		case STATE_HIDE:
			[view setNeedsDisplay:YES];
			[_button_bar hide];
			[_button_bar2 hide];
			[_capture_controller enableMouseEventInWindow];
			break;
			
		case STATE_NOSELECTED:
			[view setNeedsDisplay:YES];
			[_button_bar hide];
			[_button_bar2 hide];
			[_capture_controller disableMouseEventInWindow];
			break;
			
		case STATE_TIMER:
			[view setNeedsDisplay:YES];
			[_button_bar hide];
			[_button_bar2 hide];
			[_capture_controller disableMouseEventInWindow];
			break;
			
		case STATE_SELECTED:
			[_button_bar show];
			[_button_bar2 hide];
			[view setNeedsDisplay:YES];
			[_capture_controller enableMouseEventInWindow];
			break;
			
		default:
			break;
	}
}


- (void)reset
{
}

- (void)setup
{
	_button_bar = [[ThinButtonBar alloc] initWithFrame:NSZeroRect];
	
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
									tooltip:NSLocalizedString(@"TimerWindow", @"")
									  group:nil
						   isActOnMouseDown:NO];
/*
	[_button_bar addButtonWithImageResource:@"icon_copy"
						 alterImageResource:@"icon_copy2"
										tag:TAG_COPY
									tooltip:NSLocalizedString(@"CopyWindow", @"")
									  group:nil
						   isActOnMouseDown:NO];
*/	
	[_button_bar addButtonWithImageResource:@"icon_record"
						 alterImageResource:@"icon_record2"
										tag:TAG_RECORD
									tooltip:NSLocalizedString(@"CaptureWindow", @"")
									  group:@"RECORD"
						   isActOnMouseDown:NO];

	[_button_bar addButtonWithImageResource:@"icon_copy"
						 alterImageResource:@"icon_copy2"
										tag:TAG_COPY
									tooltip:NSLocalizedString(@"CopyWindow", @"")
									  group:@"RECORD"
						   isActOnMouseDown:NO];
	
	[_button_bar addButtonWithImageResource:@"icon_continuous"
						 alterImageResource:@"icon_continuous2"
										tag:TAG_CONTINUOUS
									tooltip:NSLocalizedString(@"ContinuouslyCapture", @"")
									  group:@"RECORD"
						   isActOnMouseDown:NO];
	
	CaptureView *view = [_capture_controller view];
	[view addSubview:_button_bar];
	[_button_bar setDelegate:self];
	
	_button_bar2 = [[ThinButtonBar alloc] initWithFrame:NSZeroRect];
	
	[_button_bar2 addButtonWithImageResource:@"icon_cancel"
						 alterImageResource:@"icon_cancel2"
										tag:TAG_CANCEL
									tooltip:NSLocalizedString(@"CancelCapture", @"")
									   group:nil
							isActOnMouseDown:NO];
	
	[_button_bar2 addButtonWithImageResource:@"icon_record"
						 alterImageResource:@"icon_record2"
										tag:TAG_RECORD
									tooltip:NSLocalizedString(@"CaptureWindow", @"")
									   group:nil
							isActOnMouseDown:NO];
	
	[view addSubview:_button_bar2];
	[_button_bar2 setDelegate:self];
	

	// setup array
	_selected_window_list = [[NSMutableArray alloc] init];
	_previous_window_id_list = [[NSMutableArray alloc] init];
}

- (void) dealloc
{
	[_selected_window_list release];
	[_previous_window_id_list release];
	[super dealloc];
}

#define IMAGEFORMAT_OFFSET_X 85.0
#define IMAGEFORMAT_OFFSET_Y 37.0
- (void)adjustButtonBar
{
	if ([_selected_window_list count]) {
		Window* wn = [_selected_window_list objectAtIndex:0];
		NSRect rect = [wn rect];
		[_button_bar setButtonBarWithFrame:rect];
		[_button_bar2 setButtonBarWithFrame:rect];
		
		[_button_bar startFlasher];

		_imageformat_display_point =
			NSMakePoint(rect.origin.x + rect.size.width -  IMAGEFORMAT_OFFSET_X
						,rect.origin.y + IMAGEFORMAT_OFFSET_Y);
	}
}

-(void)saveSelectedWindowIDListToPreviousList
{
	[_previous_window_id_list removeAllObjects];
	for (Window* window in _selected_window_list) {
		[_previous_window_id_list addObject:[NSNumber numberWithUnsignedInt:[window windowID]]];
	}
	if ([_selected_window_list count] > 0) {
		_previous_main_work_space = [[_selected_window_list objectAtIndex:0] workspace];
	} else {
		_previous_main_work_space = 0;
	}
}
-(CGWindowID)restoreSelectedWindowIDListFromPreviousList
{
	NSArray* windowList = [self getWindowList];

	[_selected_window_list removeAllObjects];

	NSNumber* num;
	CGWindowID windowID;
	CGWindowID topID = 0;
	int workspace;
	for (num in _previous_window_id_list) {
		windowID = [num unsignedIntValue];
		for (Window* window in windowList) {
			if ([window windowID] == windowID) {
				[_selected_window_list addObject:window];
				if (!topID) {
					topID = windowID;
					workspace = [window workspace];
				}
			}
		}
	}
	if (workspace == _previous_main_work_space) {
		return topID;
	} else {
		[_selected_window_list removeAllObjects];
		return 0;
	}
}

- (BOOL)startWithObject:(id)object
{
	int state;
	_current_window_id = 0;

	[self changedImageFormatTo:
	 [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue]];

	if ([_previous_window_id_list count] > 0 &&
		[_capture_controller isSameHandlerWhenPreviousCapture]) {
		state = STATE_SELECTED;
		_current_window_id = [self restoreSelectedWindowIDListFromPreviousList];
		[self adjustButtonBar];
	}
	
	if (!_current_window_id) {
		Window* wn = [self topWindow];
		if (wn) {
			state = STATE_SELECTED;
			[_selected_window_list addObject:wn];
			_current_window_id = [wn windowID];
			[self adjustButtonBar];
		} else {
			//		state = STATE_NOSELECTED;
			NSLog(@"no-selected");
			return NO;
		}
	}
	[self changeState:state];
	
	return YES;
}

- (void)tearDown
{
	[self changeState:STATE_HIDE];
	[self saveSelectedWindowIDListToPreviousList];
	[_selected_window_list removeAllObjects];
}

- (void)drawImageFormatDisplay
{
	[ImageFormat drawImageFormatDisplayAt:_imageformat_display_point];
}

- (void)drawRect:(NSRect)rect
{
	switch (_state) {
		case STATE_SELECTED:
			[self drawBackground:rect];
			
			NSPoint p;
			NSRect w_rect;
			
			for (Window* window in [_selected_window_list reverseObjectEnumerator]) {
				w_rect = [window rect];
				
				[[NSColor clearColor] set];
				NSRectFill(w_rect);
				
				p = NSMakePoint(w_rect.origin.x, w_rect.origin.y+w_rect.size.height);
				[[window image] dissolveToPoint:p fraction:0.8];
				[[NSColor grayColor] set];
				NSFrameRectWithWidth(w_rect, 0.5);
				
			}
			[self drawImageFormatDisplay];
			break;
			
		case STATE_TIMER:
			for (Window* window in _selected_window_list) {
				[self drawSelectedBoxRect:[window rect] Counter:_animation_counter];
			}
			break;

		case STATE_NOSELECTED:
			break;
			
		case STATE_HIDE:
			break;

		case STATE_TRANSITION:
			[[_capture_controller transition] draw];
			break;
	}
}

- (void)mouseMoved:(NSEvent *)theEvent
{
}

- (void)selectWindow:(Window*)selected_window isShiftKey:(BOOL)is_shiftkey
{
	[selected_window retain];
	if (is_shiftkey) {
		if ([_selected_window_list containsObject:selected_window]) {
			if ([_selected_window_list count] > 1) {
				[_selected_window_list removeObject:selected_window];
			}
		} else {
			[_selected_window_list addObject:selected_window];
		}
	} else {
		[_selected_window_list removeAllObjects];
		[_selected_window_list addObject:selected_window];
	}
	_current_window_id = [selected_window windowID];
	[selected_window release];

	[_selected_window_list sortUsingSelector:@selector(compare:)];
	[self adjustButtonBar];
	
	[[_capture_controller view] setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	BOOL is_shiftkey = ([theEvent modifierFlags] & NSShiftKeyMask) ? YES : NO;
	
	// (0) definitions
//	NSRect pre_rect = _spot_rect;
	NSPoint cp = [[_capture_controller view] convertPoint:[theEvent locationInWindow]  fromView:nil];
	BOOL hit_flag = NO;
	Window* selected_window;

	// (1) search a window on mouse down (already selected)
	for (Window* swn in _selected_window_list) {
		if (NSPointInRect(cp, [swn rect])) {
			hit_flag = YES;
			selected_window = swn;
			break;
		}
	}

	// (2) search a window on mouse down (new)
	if (!hit_flag) {
		for (Window* window in [self getWindowList]) {
			
			if (![self isTargetWindow:window]) {
				continue;
			}
			if (NSPointInRect(cp, [window rect])) {
				hit_flag = YES;
				selected_window = window;
				break;
			}
		}
	}
	
	// (3) managing spot window list
	if (hit_flag) {
		[self selectWindow:selected_window isShiftKey:is_shiftkey];
	}

}

- (CGImageRef)capture
{
	return [self cgimageWithWindowList:_selected_window_list
								cgrect:CGRectNull];
}

-(void)clickedAtTag:(NSNumber*)tag  event:(NSEvent*)event
{
	switch ([tag intValue]) {
		case TAG_CANCEL:
			[_capture_controller cancel];
			break;
			
		case TAG_TIMER:
			[self changeState:STATE_TIMER];
			[_capture_controller startTimerOnClient:self
											  title:NSLocalizedString(@"TimerTitleWindow", @"")
											  image:nil];
			break;

		case TAG_COPY:
			[_capture_controller copyImage:[self capture]
								imageFrame:[Window unionNSRectWithWindowList:_selected_window_list]];
			[_capture_controller exit];
			break;

		case TAG_CONTINUOUS:
			[_capture_controller setContinouslyFlag:YES];
			[_capture_controller saveImage:[self capture]
								imageFrame:[Window unionNSRectWithWindowList:_selected_window_list]];
			break;

		case TAG_CONFIG:
			[_capture_controller openWindowConfigMenuWithView:nil event:event];
			[[_capture_controller view] setNeedsDisplay:YES];
			break;
			
		case TAG_RECORD:
			[_capture_controller setContinouslyFlag:NO];
			[_capture_controller saveImage:[self capture]
								 imageFrame:[Window unionNSRectWithWindowList:_selected_window_list]];
			/*
			 CGImageRef cgimage;
			cgimage = [self cgimageWithWindowList:_selected_window_list
										   cgrect:CGRectNull
									ignoreOptions:YES];
			_state = STATE_TRANSITION;
			[[_capture_controller transition] startWithTarget:self CGImage:cgimage];
			 */
			[_capture_controller exit];
			break;
			
		default:
			[_capture_controller cancel];
			break;
	}
}

- (void)moveSelectedWinodowDiection:(BOOL)direction increment:(NSInteger)increment
{
	NSArray* list = [self getSortedWindowListDirection:direction];
	NSMutableArray* target_list = [NSMutableArray array];
	for (Window* window in list) {
		if ([self isTargetWindow:window]) {
			[target_list addObject:window];
		}
	}

	if ([target_list count] == 0) {
		return;
	}

	int index = 0;
	for (Window* window in target_list) {
		if ([window windowID] == _current_window_id) {
			break;
		}
		index++;
	}
	if (index == [target_list count]) {
		return;
	}
	
	index += increment;
	if (index < 0) {
		index = [target_list count] - 1;
	} else if (index >= [target_list count]) {
		index = 0;
	}
	
	Window* selected_window = [target_list objectAtIndex:index];

	[self selectWindow:selected_window isShiftKey:NO];
}


- (void)keyDown:(NSEvent *)theEvent
{
	[super keyDown:theEvent];
	
	int command_flag = [theEvent modifierFlags] & NSCommandKeyMask;
	int option_flag = [theEvent modifierFlags] & NSAlternateKeyMask;

	switch ([theEvent keyCode]) {
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
			// space key
		case 49:
			// return key
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
			[self moveSelectedWinodowDiection:YES increment:-1];
			break;
		case 124:
			// right
			[self moveSelectedWinodowDiection:YES increment:1];
			break;
		case 125:
			// down
			[self moveSelectedWinodowDiection:NO increment:1];
			break;
		case 126:
			// up
			[self moveSelectedWinodowDiection:NO increment:-1];
			break;
		default:
			break;
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

- (void)updateWindows
{
	// sort by lastest order
	NSMutableArray *remove_list = [NSMutableArray array];
	NSMutableDictionary *id_order_list = [NSMutableDictionary dictionary];

	for (Window* window in [self getWindowList]) {
		[id_order_list setObject:window forKey:[window numberWindowID]];
	}
	
	for (Window* window in _selected_window_list) {
		Window* window2 = [id_order_list objectForKey:[window numberWindowID]];
		if (window2) {
			[window setOrder:[window2 order]];
			[window setRect:[window2 rect]];
		} else {
			[remove_list addObject:window];
			//[_selected_window_list removeObject:wn];
		}
	}
	for (Window* window in remove_list) {
		[_selected_window_list removeObject:window];
	}
}

- (void)timerCounted:(TimerController*)controller
{
	_animation_counter++;
	[self updateWindows];
	CaptureView* view = [_capture_controller view];
	[view setNeedsDisplay:YES];
}

- (void)timerFinished:(TimerController*)controller
{
	[self updateWindows];	
	
	NSMutableArray* menu_array = [NSMutableArray array];
	
	for (Window* window in [self getWindowList]) {
		
		if ([window layer] == kCGPopUpMenuWindowLevel && ![window isDock]) {
			// NOTE: (x)button in Dashoard at left-bottom, the layer number is 101 (It's popupmenu level).
			[menu_array addObject:window];
		}
	}
	
	for (Window* window in menu_array) {
		for (Window* window2 in [_selected_window_list objectEnumerator]) {
			if ([window ownerPID] == [window2 ownerPID]) {
//				[_selected_window_list addObject:window];
				[_selected_window_list insertObject:window atIndex:0];
				break;
			}
		}
	}
	
	[_selected_window_list sortUsingSelector:@selector(compare:)];

	if ([controller isCopy]) {
		[_capture_controller copyImage:[self capture] withMouseCursorInWindowList:_selected_window_list imageFrame:[Window unionNSRectWithWindowList:_selected_window_list]];

		[_capture_controller exit];
		
	} else if ([controller isContinous]) {
		[_capture_controller setContinouslyFlag:YES];
		[_capture_controller saveImage:[self capture] withMouseCursorInWindowList:_selected_window_list imageFrame:[Window unionNSRectWithWindowList:_selected_window_list]];
		[controller start];
		
	} else {
		// NORMAL
		[_capture_controller saveImage:[self capture] withMouseCursorInWindowList:_selected_window_list imageFrame:[Window unionNSRectWithWindowList:_selected_window_list]];
		[_capture_controller openViewerWithLastfile];
		[_capture_controller exit];
	}
	
	
}

- (void)timerCanceled:(TimerController*)controller
{
	NSArray* current_list = [self getWindowList];
	NSMutableArray* delete_list = [NSMutableArray array];

	for (Window* window in _selected_window_list) {
		BOOL hit = NO;
		for (Window* window2 in current_list) {
			if ([window windowID] == [window2 windowID]) {
				hit = YES;
				[window updateImage];
				break;
			}
		}
		if (!hit) {
			[delete_list addObject:window];
		}
	}
	
	for (Window* window in delete_list) {
		[_selected_window_list removeObject:window];
	}

	if ([_selected_window_list count] > 0) {
		[self changeState:STATE_SELECTED];
		[self adjustButtonBar];
	} else {
		if (![self startWithObject:nil]) {
			[_capture_controller cancel];
		}
	}
	
}

- (void)timerPaused:(TimerController*)controller
{
}

- (void)timerRestarted:(TimerController*)controller
{
}

- (void)openConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	[_capture_controller openWindowConfigMenuWithView:view event:event];
}

// callback
- (void)finishTransition
{
	NSLog(@"finished");
	[_capture_controller exit];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [super menuForEvent:theEvent];
}

- (void)setupQuickConfigMenu:(NSMenu*)menu
{
	[super setupQuickConfigMenu:menu];
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
