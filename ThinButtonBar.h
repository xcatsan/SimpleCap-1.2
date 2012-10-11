//
//  ThinButtonBar.h
//  Button
//
//  Created by hashi on 08/05/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum SC_BUTTON_POSITION {
	SC_BUTTON_POSITION_CENTER,
	SC_BUTTON_POSITION_CENTER_BOTTOM,
	SC_BUTTON_POSITION_LEFT_TOP,
	SC_BUTTON_POSITION_RIGHT_TOP,
	SC_BUTTON_POSITION_LEFT_BOTTOM,
	SC_BUTTON_POSITION_RIGHT_BOTTOM
};


@class ThinButton;
@interface ThinButtonBar : NSView {

	NSMutableArray*			_list;
	NSMutableDictionary*	_group_list;
	CGFloat					_offsetX;
	CGFloat					_offsetY;
	NSTrackingArea*			_tracking_area;
	id						_delegate;
	ThinButton*				_pushed_button;
	int						_position;
	
	BOOL					_is_shadow;
	CGFloat					_marginY;
	NSPoint					_draw_offset;
	BOOL					_popup_menu_mode;
	
	BOOL					_while_flasher;
	float					_flasher_alpha;
	NSTimer*				_flasher_timer;
	int						_flasher_step;
}

- (void)addButtonWithImageResource:(NSString*)resource alterImageResource:(NSString*)resource2 tag:(UInt)tag tooltip:(NSString*)tooltip group:(NSString*)group isActOnMouseDown:(BOOL)is_act_mouse_down;
- (void)setDelegate:(id)delegate;
- (void)reset;
- (void)setButtonBarWithFrame:(NSRect)frame;
- (void)setPosition:(int)position;
- (void)resetGroup:(NSString*)group;
- (void)switchGroup:(NSString*)group;

- (void)setShadow:(BOOL)is_shadow;
- (void)setDrawOffset:(NSPoint)offset;

- (void)show;
- (void)hide;
- (void)update;

- (void)setPopupMenuMode:(BOOL)mode;

- (void)setMarginY:(CGFloat)marginY;

- (void)startFlasher;

- (NSSize)size;

@end
