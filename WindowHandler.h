//
//  WindowHandler.h
//  SimpleCap
//
//  Created by - on 08/06/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"

@class ThinButtonBar;
@interface WindowHandler : HandlerBase <Handler, TimerClient> {

	ThinButtonBar*	_button_bar;
	ThinButtonBar*	_button_bar2;
	int				_state;
	NSMutableArray*	_selected_window_list;
	
	CGWindowID _current_window_id;
	
	NSMutableArray* _previous_window_id_list;
	int _previous_main_work_space;
	
	NSPoint _imageformat_display_point;
}
@end
