//
//  TimerController.h
//  TimerDialog-01
//
//  Created by - on 08/06/09.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimerClient.h"

@class ThinButtonBar;
@class TimerWindow;
@class TimerWindowView;
@interface TimerController : NSObject {

	int				_state;
	NSTimeInterval	_interval;		// [sec]
	int				_times;			// [sec]
	int				_count;			// 1sec
	int				_count_dec;		// 1/10sec
	id<TimerClient>	_client;
	NSTimer*		_timer;
	NSString*		_title;

	ThinButtonBar*		_button_bar;
	ThinButtonBar*		_button_bar2;
	TimerWindow*		_window;
	TimerWindowView*	_view;
	
	NSImage*			_image;
	
	BOOL				_is_copy;
	BOOL				_is_continuous;
}
- (void)start;
- (void)pause;
- (void)cancel;

- (void)setTimes:(int)times;
- (void)setTimerClient:(id<TimerClient>)client;
- (void)setTitle:(NSString*)title;
- (void)setImage:(NSImage*)image;

- (BOOL)isRunning;
- (int)count;
- (int)times;
- (NSTimeInterval)interval;
- (int)lastCount;

- (NSString*)title;
- (NSImage*)image;

- (void)hideWindow;
- (void)showWindow;

- (void)keyDown:(NSEvent *)theEvent;
- (void)flagsChanged:(NSEvent *)theEvent;
- (BOOL)isCopy;
- (BOOL)isContinous;
- (void)changedImageFormatTo:(int)image_format;

@end


