//
//  FukidashiController.m
//  Fukidashi
//
//  Created by - on 08/12/06.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//
//08/12/11 19:10:08 SimpleCap[15245] _NXPlaceWindow: error setting window shape (1007) 
//08/12/11 19:10:08 SimpleCap[15245] _NSShapePlainWindow: error setting window shape (1007) 

#import "FukidashiController.h"
#import "FukidashiWindow.h"
#import "FukidashiView.h"
#import "Window.h"
#import "Screen.h"

enum FUKIDASHI_STATE {
	FUKIDASHI_STATE_HIDE,
	FUKIDASHI_STATE_SHOW,
	FUKIDASHI_STATE_FADEOUT
};

#define FUKIDASHI_TIME_INTERVAL 0.1
#define FUKIDASHI_SHOW_TIME		1.5
#define FUKIDASHI_FADEOUT_TIME	1.75

@implementation FukidashiController

static FukidashiController* _controller = nil;
+(FukidashiController*)sharedConroller
{
	if (_controller == nil) {
		_controller = [[FukidashiController alloc] init];
	}
	return _controller;
}

- (id)init
{
	self = [super init];
	if (self) {
		_window = [[FukidashiWindow alloc] init];
		_view = [[FukidashiView alloc] init];
		[_window setContentView:_view];
		_state = FUKIDASHI_STATE_HIDE;
		_showtime = FUKIDASHI_SHOW_TIME;
	}
	return self;
}
-(void) dealloc
{
	[_window release];
	[_view release];
	[super dealloc];
}


- (void)changeState:(int)state
{
	switch (state) {
		case FUKIDASHI_STATE_HIDE:
			[_window orderOut:self];
			break;

		case FUKIDASHI_STATE_SHOW:
			if (_state != FUKIDASHI_STATE_HIDE && [_timer isValid]) {
				[_timer invalidate];
			}
			_count = 0;
			[_window setContentSize:[_view areaSize]];
			[_window setAlphaValue:1.0];
			[_window makeKeyAndOrderFront:self];
			_timer = [NSTimer timerWithTimeInterval:FUKIDASHI_TIME_INTERVAL
											 target:self
										   selector:@selector(callBack:)
										   userInfo:nil
											repeats:YES];
			[[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
			break;

		case FUKIDASHI_STATE_FADEOUT:
			_count = 0;
			break;
		default:
			break;
	}
	_state = state;
}

- (void)callBack:(NSTimer*)timer
{
	_count++;
	switch (_state) {
		case FUKIDASHI_STATE_SHOW:
			if (_count >= (int)((float)_showtime/FUKIDASHI_TIME_INTERVAL)) {
				[self changeState:FUKIDASHI_STATE_FADEOUT];
			}
			break;
		case FUKIDASHI_STATE_FADEOUT:
			if (_count >= (int)(FUKIDASHI_FADEOUT_TIME/FUKIDASHI_TIME_INTERVAL)) {
				[self changeState:FUKIDASHI_STATE_HIDE];
				[timer invalidate];
			} else {
				[_window setAlphaValue:(1.0-_count*FUKIDASHI_TIME_INTERVAL/FUKIDASHI_FADEOUT_TIME)];
			}
			break;
		default:
			break;
	}
}


- (void)showMessage:(NSString*)message
{
	[_view setMessage:message];
	NSPoint triangle_point = [_view trianglePoint];

	Window* status_bar_window = [Window statusBarWindow];
	NSRect rect = [status_bar_window rect];
	NSPoint p;	
	p.x = rect.origin.x + rect.size.width/2.0 - 2;
	p.y = [[Screen defaultScreen] menuScreenFrame].size.height - rect.origin.y - rect.size.height - 3;
//	NSPoint p = _base_position;
	p.x -= triangle_point.x;
	p.y -= triangle_point.y;
	[_window setFrameOrigin:p];

	[self changeState:FUKIDASHI_STATE_SHOW];
}

- (void)setBasePosition:(NSPoint)p
{

	_base_position = p;
}

- (void)setShowTime:(int)showtime
{
	_showtime = showtime;
}
- (void)showMessage:(NSString*)message At:(NSPoint)p
{
	[self setBasePosition:p];
	[self showMessage:message];
}


@end
