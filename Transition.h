//
//  Transition.h
//  SimpleCap
//
//  Created by - on 08/10/13.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Transition : NSObject {

	NSNumber *_inputTime;
	NSNumber *_inputWidth;
	NSNumber *_inputScale;
	NSNumber *_framePerSec;
	NSNumber *_totalSec;
	
	CIFilter* _filter;
	NSInteger _count;
	
	NSView* _view;
	BOOL _finished;
	id _target;
}

@property (retain) NSNumber* inputTime;
@property (retain) NSNumber *inputWidth;
@property (retain) NSNumber *inputScale;
@property (retain) NSNumber *framePerSec;
@property (retain) NSNumber *totalSec;

- (id)initWithView:(NSView*)view;
- (void)draw;
- (void)startWithTarget:(id)target CGImage:(CGImageRef)cgimage;

@end
