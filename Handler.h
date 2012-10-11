//
//  Handler.h
//  SimpleCap
//
//  Created by - on 08/03/23.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowLayer.h"

@protocol Handler

- (void)reset;
- (void)setup;
- (BOOL)startWithObject:(id)object;
- (void)tearDown;
- (void)drawRect:(NSRect)rect;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void)setupQuickConfigMenu:(NSMenu*)menu;
- (void)changedImageFormatTo:(int)image_format;

// property
- (NSInteger)windowLevel;

@end
