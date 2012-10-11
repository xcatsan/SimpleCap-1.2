//
//  ThinButton.h
//  Button
//
//  Created by 橋口 - on 08/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum TB_STATE {
	TB_STATE_NORMAL,
	TB_STATE_OVER,
	TB_STATE_PUSHED
};

@interface ThinButton : NSObject {
	
	NSImage		*_image1;
	NSImage		*_image2;
	NSRect		_frame;
	UInt		_state;
	UInt		_tag;
	NSString	*_tooltip;
	NSString	*_group;
	
	BOOL		_act_on_mousedown;
}
- (id)initWithImage:(NSImage*)image1 alterImage:(NSImage*)image2 frame:(NSRect)frame tag:(UInt)tag tooltip:(NSString*)tooltip group:(NSString*)group isActOnMouseDown:(BOOL)is_act_mouse_down;

- (BOOL)hitAtPoint:(NSPoint)point;

- (UInt)state;
- (void)setState:(UInt)state;

- (NSImage*)image;
- (NSImage*)alterImage;

- (NSRect)frame;
- (UInt)tag;

- (NSString*)tooltip;
- (NSString*)group;

- (BOOL)isActOnMouseDown;

@end
