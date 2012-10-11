//
//  SelectionHandler.h
//  SimpleCap
//
//  Created by - on 08/03/16.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"

@class ThinButtonBar;
//@class SelectionHistory;
@interface SelectionHandler : HandlerBase <Handler, TimerClient> {
	NSRect _rect;
	id _delegate;
	NSShadow *_shadow;
	CGFloat _resize_unit;

	int _state;
	int _previous_state;

	BOOL _is_display_info;
	BOOL _display_info;
	
	BOOL _display_imageformat;
	
	ThinButtonBar *_button_bar;		// operation buttons
	ThinButtonBar *_button_bar2;	// size history
	
	BOOL _display_knob;
	
//	SelectionHistory* _selection_history;
	
	NSSize _mouse_pointer_offset;
	
 }
-(void)setRubberBandFrame:(NSRect)frame;

@end
