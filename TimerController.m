//
//  TimerController.m
//  TimerDialog-01
//
//  Created by - on 08/06/09.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "TimerController.h"
#import "TimerWindow.h"
#import "TimerWindowView.h"
#import "ThinButtonBar.h"
#import "ButtonTags.h"
#import "UserDefaults.h"
#import "ImageFormat.h"

#define MIN_TIMES	3
enum TIMER_STATE {
	TIMER_STATE_STOP,
	TIMER_STATE_RUNNING,
	TIMER_STATE_PAUSE
};

#define TC_BUTTON_MARGIN_Y1 -12
#define TC_BUTTON_MARGIN_Y2 -17
@implementation TimerController

- (void)reset
{
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
	[_button_bar resetGroup:@"START_PAUSE"];
	[_button_bar switchGroup:@"START_PAUSE"];
	
	_state = TIMER_STATE_STOP;
	_count = 0;
	_count_dec = 0;
}

- (id)init
{
	self = [super init];
	if (self) {
		_interval = 0.1;
		_timer = nil;
		_title = @"";
		[self reset];
		
		_window = [[TimerWindow alloc] initWithController:self];
		_view = [[TimerWindowView alloc] initWithFrame:[_window frame]];
		[_view setTimerController:self];

		[_window setContentView:_view];
		
		_button_bar = [[ThinButtonBar alloc] initWithFrame:NSZeroRect];
		
		[_button_bar addButtonWithImageResource:@"icon_cancel"
							 alterImageResource:@"icon_cancel2"
											tag:TAG_CANCEL_TIMER
										tooltip:NSLocalizedString(@"CancelTimer", @"")
										  group:nil
							   isActOnMouseDown:NO];

		[_button_bar addButtonWithImageResource:@"icon_config"
							 alterImageResource:@"icon_config2"
											tag:TAG_CONFIG
										tooltip:NSLocalizedString(@"QuickConfig", @"")
										  group:nil
							   isActOnMouseDown:YES];
		
		[_button_bar addButtonWithImageResource:@"icon_start_timer"
							 alterImageResource:@"icon_start_timer2"
											tag:TAG_START_TIMER
										tooltip:NSLocalizedString(@"StartTimer", @"")
										  group:@"START_PAUSE"
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"icon_pause_timer"
							 alterImageResource:@"icon_pause_timer2"
											tag:TAG_PAUSE_TIMER
										tooltip:NSLocalizedString(@"PauseTimer", @"")
										  group:@"START_PAUSE"
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"icon_record"
							 alterImageResource:@"icon_record2"
											tag:TAG_RECORD
										tooltip:NSLocalizedString(@"CaptureImmediately", @"")
										  group:@"RECORD"
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"icon_copy"
							 alterImageResource:@"icon_copy2"
											tag:TAG_COPY
										tooltip:NSLocalizedString(@"CopyImmediately", @"")
										  group:@"RECORD"
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"icon_continuous"
							 alterImageResource:@"icon_continuous2"
											tag:TAG_CONTINUOUS
										tooltip:NSLocalizedString(@"ContinuouslyCapture", @"")
										  group:@"RECORD"
							   isActOnMouseDown:NO];
		
		[_button_bar setMarginY:TC_BUTTON_MARGIN_Y1];
		[_view addSubview:_button_bar];
		[_button_bar setDelegate:self];
		[_button_bar setPosition:SC_BUTTON_POSITION_RIGHT_BOTTOM];
		[_button_bar setButtonBarWithFrame:[_view frame]];
		
		[_button_bar switchGroup:@"START_PAUSE"];

		
		_button_bar2 = [[ThinButtonBar alloc] initWithFrame:NSZeroRect];
		
		[_button_bar2 addButtonWithImageResource:@"icon_reset"
							  alterImageResource:@"icon_reset2"
											 tag:TAG_RESET_COUNT
										 tooltip:NSLocalizedString(@"ResetCount", @"")
										   group:nil
								isActOnMouseDown:NO];
		
		[_button_bar2 addButtonWithImageResource:@"icon_minus"
							  alterImageResource:@"icon_minus2"
											 tag:TAG_MINUS_COUNT
										 tooltip:NSLocalizedString(@"MinusCount", @"")
										   group:nil
								isActOnMouseDown:NO];
		
		[_button_bar2 addButtonWithImageResource:@"icon_plus"
							  alterImageResource:@"icon_plus2"
											 tag:TAG_PLUS_COUNT
										 tooltip:NSLocalizedString(@"PlusCount", @"")
										   group:nil
								isActOnMouseDown:NO];

		[_button_bar2 setMarginY:TC_BUTTON_MARGIN_Y2];
		[_view addSubview:_button_bar2];
		[_button_bar2 setDelegate:self];
		[_button_bar2 setShadow:NO];
		[_button_bar2 setPosition:SC_BUTTON_POSITION_LEFT_BOTTOM];
		[_button_bar2 setButtonBarWithFrame:[_view frame]];
		
		[_button_bar show];
		[_button_bar2 show];
		
		[self hideWindow];
		
		_times = [[UserDefaults valueForKey:UDKEY_TIMER_SECOND] intValue];
	}
	return self;
}

- (void) dealloc
{
	if (_timer) {
		[_timer invalidate];
	}
	[_button_bar release];
	[_view release];
	[_window release];
	[_title release];
	[_image release];
	[super dealloc];
}


- (void)callBack:(NSTimer*)timer
{
	if (_state == TIMER_STATE_PAUSE) {
		return;
	}

	_count_dec++;
	if (_count_dec >= 10) {
		_count++;
		_count_dec = 0;
	}
	[_view setNeedsDisplay:YES];
	if (_count >= _times) {
		[self reset];					// must be first !
		[_client timerFinished:self];

	} else {
		[_client timerCounted:self];
	}
}

- (void)start
{
	/*
	_is_copy = NO;
	_is_continuous = NO;
	 */
	[self flagsChanged:nil];

	/*
	[self changedImageFormatTo:
	 [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue]];
	 */
	
	if (_state == TIMER_STATE_STOP) {
		_timer = [NSTimer timerWithTimeInterval:_interval
										 target:self
									   selector:@selector(callBack:)
									   userInfo:nil
										repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
		_state = TIMER_STATE_RUNNING;
//		_state = TIMER_STATE_PAUSE;
//		[_button_bar switchGroup:@"START_PAUSE"];

		[_client timerStarted:self];
		
		[_button_bar startFlasher];
		[_view setNeedsDisplay:YES];

	} else if (_state == TIMER_STATE_PAUSE) {
		_state = TIMER_STATE_RUNNING;
		[_client timerRestarted:self];
	}
}

- (void)pause
{
	if (_state == TIMER_STATE_RUNNING) {
		_state = TIMER_STATE_PAUSE;
		[_client timerPaused:self];
	}
}

- (void)cancel
{
	if (_state == TIMER_STATE_RUNNING || _state == TIMER_STATE_PAUSE) {
		[self reset];
		[_client timerCanceled:self];
		[_window orderOut:self];

	}
}

- (void)setTimes:(int)times
{
	_times = times;
	[UserDefaults setValue:[NSNumber numberWithInt:times] forKey:UDKEY_TIMER_SECOND];
	[UserDefaults save];
}

- (void)setTimerClient:(id<TimerClient>)client
{
	_client = client;
}

- (BOOL)isRunning
{
	if (_state == TIMER_STATE_RUNNING) {
		return YES;
	} else {
		return NO;
	}
}

- (int)count
{
	return _count;
}

- (int)times
{
	return _times;
}

- (NSTimeInterval)interval
{
	return _interval;
}


- (int)lastCount
{
	if (_state == TIMER_STATE_STOP) {
		return 0;
	}

	int ret = _times - _count;
	if (ret < 0) {
		ret = 0;
	}
	return ret;
}

-(void)clickedAtTag:(NSNumber*)tag event:(NSEvent*)event
{
	BOOL is_shiftkey = ([event modifierFlags] & NSShiftKeyMask) ? YES : NO;
	BOOL restart_flag = NO;
	int dc = 1;
	if (is_shiftkey) {
		dc = 10;
	}
	
	int times_tmp;

	switch ([tag intValue]) {
		case TAG_START_TIMER:
			[self start];
			[_view setNeedsDisplay:YES];
			[_button_bar switchGroup:@"START_PAUSE"];
			break;
			
		case TAG_PAUSE_TIMER:
			[self pause];
			[_view setNeedsDisplay:YES];
			[_button_bar switchGroup:@"START_PAUSE"];
			break;

		case TAG_RECORD:
			[self reset];					// must be first !
			[_client timerFinished:self];
			break;

		case TAG_COPY:
			[self reset];					// must be first !
			[_client timerFinished:self];
			break;
			
		case TAG_CONTINUOUS:
			[self reset];					// must be first !
			[_client timerFinished:self];
			break;
			
		case TAG_CONFIG:
			if (_state == TIMER_STATE_RUNNING) {
				restart_flag = YES;
				[self pause];
			}
			[_view setNeedsDisplay:YES];
			[_client openConfigMenuWithView:_view event:event];
			if (restart_flag) {
				[self start];
			}
			[_view setNeedsDisplay:YES];
			break;
			
		case TAG_CANCEL_TIMER:
			[self cancel];
			break;
			
		case TAG_PLUS_COUNT:
			if (_state == TIMER_STATE_RUNNING) {
				[_button_bar switchGroup:@"START_PAUSE"];
			}
			[self pause];
			if ((_count-dc) < 0) {
				[self setTimes:(_times + dc - _count)];
				_count = 0;
			} else {
				_count -= dc;
			}
			_count_dec = 0;
			[_view setNeedsDisplay:YES];
			break;
			
		case TAG_MINUS_COUNT:
			if (_state == TIMER_STATE_RUNNING) {
				[_button_bar switchGroup:@"START_PAUSE"];
			}
			[self pause];
			times_tmp = _times - dc;
			_count -= dc;
			if (times_tmp < MIN_TIMES) {
				times_tmp = MIN_TIMES;
			}
			[self setTimes:times_tmp];
			if (_count < 0) {
				_count = 0;
			}
			_count_dec = 0;
			[_view setNeedsDisplay:YES];
			break;

		case TAG_RESET_COUNT:
			if (_state == TIMER_STATE_RUNNING) {
				[_button_bar switchGroup:@"START_PAUSE"];
			}
			[self pause];
			[self setTimes:DEFAULT_TIMER_TIMES];
			_count = 0;
			_count_dec = 0;
			[_view setNeedsDisplay:YES];
			break;

		default:
			break;
	}
}

- (void)hideWindow
{
	[self cancel];
	[_window orderOut:self];
}

- (void)showWindow
{
	[_window makeKeyAndOrderFront:self];
}
- (void)setTitle:(NSString*)title
{
	[title retain];
	[_title release];
	_title = title;
}
- (NSString*)title
{
	return _title;
}
- (void)setImage:(NSImage*)image
{
	[image retain];
	[_image release];
	_image = image;
}
- (NSImage*)image
{
	return _image;
}

- (void)keyDown:(NSEvent *)theEvent;
{
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	NSUInteger modifierFlags;
	
	if (theEvent) {
		modifierFlags = [theEvent modifierFlags];
	} else {
		modifierFlags = [[NSApp currentEvent] modifierFlags];
	}
	
	_is_copy = NO;
	_is_continuous = NO;

	[_button_bar resetGroup:@"RECORD"];
	if (modifierFlags & NSCommandKeyMask) {
		_is_copy = YES;
		[_button_bar switchGroup:@"RECORD"];
	} else if (modifierFlags & NSAlternateKeyMask) {
		[_button_bar switchGroup:@"RECORD"];
		[_button_bar switchGroup:@"RECORD"];
		_is_continuous = YES;
	} else {
		if ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_CLIPBOARD) {
			_is_copy = YES;
			[_button_bar switchGroup:@"RECORD"];
		}
	}
	[_button_bar setNeedsDisplay:YES];
}
- (BOOL)isCopy
{
	return _is_copy;
}
- (BOOL)isContinous
{
	return _is_continuous;
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
