//
//  SimpleViewerWindow.m
//  SimpleCap
//
//  Created by - on 08/12/19.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerPanel.h"
#import "SimpleViewerController.h"

@implementation SimpleViewerPanel

- (id)initWithController:(SimpleViewerController*)controller
{
	NSRect frame = NSZeroRect;
	self = [super initWithContentRect:frame
							styleMask:NSResizableWindowMask|NSHUDWindowMask| NSClosableWindowMask | NSUtilityWindowMask | NSNonactivatingPanelMask
							  backing:NSBackingStoreBuffered
								defer:NO];

	if (self) {
		_controller = [controller retain];
		[self setDisplaysWhenScreenProfileChanges:YES];
//		[self setHidesOnDeactivate:NO];
//		[self setIgnoresMouseEvents:NO];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
		[self setTitle:@"Simple Viewer"];
		[self setMovableByWindowBackground:NO];
	}
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void) dealloc
{
	[_controller release];
	[super dealloc];
}


#define FADE_DURATION	0.15
#define ZOOM_DURATION	0.35
- (void)show
{
	if (![self isVisible]) {
		[self setAlphaValue:0.0];
		[self makeKeyAndOrderFront:nil];
//		[NSApp activateIgnoringOtherApps:YES];
	}
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
	[dict setObject:[NSValue valueWithRect:[self frame]] forKey:NSViewAnimationStartFrameKey];
	[dict setObject:[NSValue valueWithRect:[self frame]] forKey:NSViewAnimationEndFrameKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:FADE_DURATION];
	[anim setAnimationCurve:NSAnimationEaseIn];
	
	[anim startAnimation];
	[anim release];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	// only in fade out situation
	[self orderOut:nil];
}

- (BOOL)isOpened
{
	if (![self isVisible] || [self alphaValue]==0) {
		return NO;
	}
	return YES;
}

- (void)hide
{
	if (![self isOpened]) {
		return;
	}
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:FADE_DURATION];
	[anim setAnimationCurve:NSAnimationEaseIn];
	
	[anim setDelegate:self];
	[anim startAnimation];
	[anim release];

}

#define SCALE_FACTOR	0.1
#define	FRAME_RATE		60
- (void)zoomInWithStartFrame:(NSRect)start_frame
{
	// QuickLookとの違い 12/27
	// (1) スムーズさに欠ける
	// (2) ウィンドウのタイトルを含む全部が拡大・縮小の対象になっている。
	[self setAlphaValue:0.0];
	[self makeKeyAndOrderFront:nil];
	
	NSRect frame;
	frame.size.width  = start_frame.size.width  * SCALE_FACTOR;
	frame.size.height = start_frame.size.height * SCALE_FACTOR;
	frame.origin.x    = start_frame.origin.x +
		(start_frame.size.width - frame.size.width) / 2.0;
	frame.origin.y    = start_frame.origin.y +
		(start_frame.size.height - frame.size.height) / 2.0;

	// adjust to screen
	NSScreen *screen = [NSScreen mainScreen];
	frame.origin.y = [screen frame].size.height - frame.origin.y;
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:[NSValue valueWithRect:frame] forKey:NSViewAnimationStartFrameKey];
	[dict setObject:[NSValue valueWithRect:[self frame]] forKey:NSViewAnimationEndFrameKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:ZOOM_DURATION];
	[anim setAnimationBlockingMode:NSAnimationBlocking];
	[anim setAnimationCurve:NSAnimationEaseIn];
	[anim setFrameRate:FRAME_RATE];
	
	[anim startAnimation];
	[anim release];
}

- (void)close
{
	[self hide];
}

- (void)keyDown:(NSEvent *)event
{
	[_controller keyDown:event];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[_controller flagsChanged:theEvent];
}

@end
