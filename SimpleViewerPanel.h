//
//  SimpleViewerWindow.h
//  SimpleCap
//
//  Created by - on 08/12/19.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SimpleViewerController;
@interface SimpleViewerPanel : NSPanel {

	SimpleViewerController* _controller;
}

- (id)initWithController:(SimpleViewerController*)controller;
- (void)show;
- (void)hide;
- (BOOL)isOpened;
- (void)zoomInWithStartFrame:(NSRect)start_frame;

@end
