//
//  CaptureView.h
//  SimpleCap
//
//  Created by - on 08/03/05.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;
@class Handler;

@interface CaptureView : NSView {

	NSTrackingArea *_tracking_area;

	Handler* _handler;
}
- (void)setHandler:(Handler*)handler;

@end
