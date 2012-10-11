//
//  HandlerBase.h
//  SimpleCap
//
//  Created by - on 08/03/23.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CaptureController;
@class Window;
@interface HandlerBase : NSObject {
	
	CaptureController* _capture_controller;

	int _animation_counter;
}
- (id)initWithCaptureController:(CaptureController*)captureController;

- (void)drawBackground:(NSRect)rect;
//- (BOOL)isDockWindow:(CFDictionaryRef)window;
- (void)keyDown:(NSEvent *)theEvent;
- (void)flagsChanged:(NSEvent *)theEvent;
- (void)setup;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void)setupQuickConfigMenu:(NSMenu*)menu;

- (NSColor*)backgroundColor;
- (NSInteger)defaultWindowLevel;

- (void)drawSelectedBoxRect:(NSRect)rect Counter:(int)counter;
- (void)drawSelectedBoxRect2:(NSRect)rect Counter:(int)counter;

- (NSArray*)getWindowListWindowID:(CGWindowID)window_id;
- (NSArray*)getWindowList;
- (NSArray*)getSortedWindowListDirection:(BOOL)direction;
- (NSArray*)getWindowAllList;
- (CGImageRef)cgimageWithWindowList:(NSArray*)list cgrect:(CGRect)cgrect;
- (CGImageRef)cgimageWithWindowList:(NSArray*)list cgrect:(CGRect)cgrect ignoreOptions:(BOOL)ignore;

// override
- (Window*)topWindow;
- (BOOL)isTargetWindow:(Window*)window;


@end
