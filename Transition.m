//
//  Transition.m
//  SimpleCap
//
//  Created by - on 08/10/13.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//
// (1) call #startWithView:CGImage:
// (2) call #draw in NSView#drawRect:
//
#import "Transition.h"

#import <QuartzCore/CoreImage.h>

@implementation Transition

@synthesize inputTime = _inputTime;
@synthesize inputWidth = _inputWidth;
@synthesize inputScale = _inputScale;
@synthesize framePerSec = _framePerSec;
@synthesize totalSec = _totalSec;

- (void) dealloc
{
	[_filter release];
	[_view release];
	[super dealloc];
}

- (void)setupFilter
{
	NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
										 pathForImageResource:@"shading"]];
	CIImage* image = [CIImage imageWithContentsOfURL:url];
	_filter = [[CIFilter filterWithName:@"CIRippleTransition"] retain];
	[_filter setDefaults];
	[_filter setValue:image forKey:kCIInputShadingImageKey];
}

- (id)initWithView:(NSView*)view
{
	self = [super init];
	if (self) {
		_view = [view retain];
		self.inputTime = [NSNumber numberWithFloat:0.0];
		self.inputWidth = [NSNumber numberWithFloat:75.0];
		self.inputScale = [NSNumber numberWithFloat:100.0];
		self.framePerSec = [NSNumber numberWithFloat:20.0];
		self.totalSec = [NSNumber numberWithFloat:1.0];
		
		[self setupFilter];
	}
	return self;
}

// (2) call this method in NSView#drawRect:
- (void)draw
{
	CIImage *output_image = [_filter valueForKey:kCIOutputImageKey];
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CIContext *ci_context = [CIContext contextWithCGContext:context options:nil];
	[ci_context drawImage:output_image atPoint:CGPointZero fromRect:[output_image extent]];
}

-(void)fire:(NSTimer*)theTimer
{
	_count++;
	float max_count = [_totalSec floatValue] * [_framePerSec floatValue];
	NSLog(@"count=%d", _count);
	if (_count > max_count) {
		[theTimer invalidate];
		_finished = YES;
		NSLog(@"finished!");
		[_target performSelector:@selector(finishTransition)];
	}
	//	_inputTime = [NSNumber numberWithFloat:(_count / max_count)];
	_inputTime = [NSNumber numberWithFloat:(_count / max_count)];
	[_filter setValue:_inputTime forKey:kCIInputTimeKey];

	[_view setNeedsDisplay:YES];
}

#define TRANSITION_PADDING	25.0
#define TRANSITION_OFFSET	TRANSITION_PADDING

- (void)startWithTarget:(id)target CGImage:(CGImageRef)cgimage
{
	_target = target;

	_finished = NO;
	_count = 0;
	CGFloat x = -TRANSITION_OFFSET;
	CGFloat y = -TRANSITION_OFFSET;
	CGFloat w = CGImageGetWidth(cgimage) + TRANSITION_PADDING*2;
	CGFloat h = CGImageGetHeight(cgimage)+ TRANSITION_PADDING*2;

	[_filter setValue:[CIVector vectorWithX:w/2.0 Y:h/2.0]
			   forKey:kCIInputCenterKey];
	[_filter setValue:[CIVector vectorWithX:x Y:y Z:w W:h]
			   forKey:kCIInputExtentKey];

	/* TODO: prevent to start dup */

	/*
	NSBitmapImageRep *bitmap_rep = [[[NSBitmapImageRep alloc] initWithCGImage:cgimage] autorelease];
	CIImage* ciimage = [[CIImage alloc] initWithBitmapImageRep:bitmap_rep];
	*/
	CIImage* ciimage = [[CIImage alloc] initWithCGImage:cgimage];

	// http://theocacao.com/document.page/350
	CGAffineTransform transform;
	transform = CGAffineTransformMakeTranslation(0.0, CGImageGetHeight(cgimage));
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	ciimage = [ciimage imageByApplyingTransform:transform];
	[_filter setValue:ciimage forKey:kCIInputImageKey];
	[_filter setValue:ciimage forKey:kCIInputTargetImageKey];

	[_filter setValue:_inputWidth forKey:kCIInputWidthKey];
	[_filter setValue:_inputScale forKey:kCIInputScaleKey];

	float interval = 1.0/[_framePerSec floatValue];
	[NSTimer scheduledTimerWithTimeInterval:interval
									 target:self
								   selector:@selector(fire:)
								   userInfo:nil
									repeats:YES];
}

@end
