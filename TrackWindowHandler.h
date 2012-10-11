//
//  TrackWindowHandler.h
//  SimpleCap
//
//  Created by - on 08/06/28.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"

@class ThinButtonBar;
@class ToolWindow;
@class Window;

@interface TrackWindowHandler : HandlerBase <Handler> {
	
	ThinButtonBar*	_button_bar;
	
	NSTimer*		_timer;
	
	BOOL			_is_display_selection;
	ToolWindow*		_tool_window;
	int				_state;

	Window*			_window;
}
@end

