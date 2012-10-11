//
//  DelegateWindow.m
//  SimpleCap
//
//  Created by - on 08/03/08.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "CaptureController.h"
#import "HandlerFactory.h"
#import "AppController.h"
#import "FileManager.h"
#import "CaptureView.h"
#import "CaptureWindow.h"
#import "Handler.h"
#import "TimerController.h"
#import "MouseCursor.h"
#import "Window.h"
#import "WindowShadow.h"
#import "Screen.h"
#import "UserDefaults.h"
#import "Transition.h"
#import "DesktopWindow.h"
#import "CaptureType.h"
#import "ImageFormat.h"


@implementation CaptureController

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_handler_factory release];
	[_view release];
	[_window release];
	[_transition release];
	
	[_timer_controller release];
	
	[_transition release];
	
	[super dealloc];
}

//
// for app controller
//
- (id)initWithAppController:(AppController*)appController
{
	self = [super init];
	if (self) {
		_app_controller = appController;
		NSRect frame = [[Screen defaultScreen] frame];
		_window = [[CaptureWindow alloc] initWithFrame:frame];
		frame.origin = NSZeroPoint;
		_view = [[CaptureView alloc] initWithFrame:frame];
		[_window setContentView:_view];
		[_window orderOut:self];
		
		_timer_controller = [[TimerController alloc] init];

		// below call -> hung up!
		// [_window setNextResponder:_view];
		
		_transition = [[Transition alloc] initWithView:_view];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(screenChanged:)
													 name:NSApplicationDidChangeScreenParametersNotification
												   object:nil];

		_handler_factory = [[HandlerFactory alloc] initWithCaptureController:self];
	}
	return self;
}

- (void)setFileManager:(FileManager*)fileManager
{
	_file_manager = fileManager;
}

- (void)startCaptureWithHandlerName:(NSString*)handlerName withObject:(id)object
{
	_current_handler = [_handler_factory handlerWithName:handlerName];

	[_view setHandler:_current_handler];
	[_view setNeedsDisplay:YES];

	[_window setLevel:[_current_handler windowLevel]];
	[_window makeKeyAndOrderFront:self];
/*
	if ([_current_handler isActivateWindow]) {
//		[NSApp activateIgnoringOtherApps:YES];	// must be YES
	}
*/
	[self setContinouslyFlag:NO];

	if ([_current_handler startWithObject:object]) {
		[_app_controller startCapture];
		_result_flag = NO;
		_cancel_flag = NO;
		_copy_flag = NO;
		_continuous_flag = NO;

	} else {
		[self exit];
	}
}

- (void)playSound
{
	if ([[UserDefaults valueForKey:UDKEY_PLAY_SOUND] boolValue]) {
		NSSound *sound = [NSSound soundNamed:@"Submarine"];
		[sound play];
	}
}

- (void)openViewerWithLastfile
{
	[_app_controller openViewerWithLastfile];
}

//
// for handlers
//
- (void)showResultMessage
{
	if (_result_flag && _copy_flag) {
		[_app_controller showMessage:NSLocalizedString(@"CopiedObjects", @"")];
	} else if (!_result_flag && !_cancel_flag) {
		[_app_controller showMessage:NSLocalizedString(@"NoCapturedObjects", @"")];
	}
}

- (void)exit
{
	[self showResultMessage];
	
	[_timer_controller hideWindow];
	[_current_handler tearDown];
	_previous_handler = _current_handler;
	[_window orderOut:self];
	
	[_app_controller exitCaptureWithCancel:_cancel_flag contiuous:_continuous_flag];
}
- (void)cancel
{
	_cancel_flag = YES;
	[self exit];
}

- (AppController*)appController
{
	return _app_controller;
}

- (void)_saveImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect offset:(NSSize)offset imageFrame:(NSRect)image_frame
{
	if (cgimage) {
		// composite with mouse cursor
		MouseCursor* cursor = [MouseCursor mouseCursor];
		NSBitmapImageRep *bitmap_rep = [[[NSBitmapImageRep alloc] initWithCGImage:cgimage] autorelease];
		CGImageRelease(cgimage);
		
		if (!NSEqualRects(rect, NSZeroRect)) {
			int is_mouse_cursor = [[UserDefaults valueForKey:UDKEY_MOUSE_CURSOR] intValue];
			
			if (is_mouse_cursor && [cursor isIntersectsRect:rect]) {
				NSPoint p = [cursor pointForDrawing];
				p.x -= rect.origin.x;
				p.y -= rect.origin.y;
				
				p.x += offset.width;
				p.y += offset.height;
				
				NSImage *image = [[[NSImage alloc] init] autorelease];
				[image addRepresentation:bitmap_rep];
				
				p.y = [image size].height - p.y;
				[image lockFocus];
				[[cursor image] compositeToPoint:p operation:NSCompositeSourceOver];
				[image unlockFocus];
				
				// re-creation bitmap rep
				bitmap_rep = [[[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]] autorelease];
			}
		}
		
		int image_format = [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue];
		if (image_format == IMAGEFORMAT_CLIPBOARD) {
			_copy_flag = YES;
		}

		if (_copy_flag) {
			// Copy to clipboard
			[self copyImageWithBitmapImageRep:bitmap_rep];
		} else {
			// Save image file
			// save to file
			NSString* filename = [_file_manager saveImage:bitmap_rep];
			if (!_continuous_flag) {
				[_app_controller openViewerWithFile:filename];
			}
			[_app_controller showMessage:[filename lastPathComponent]];
		}
		
		_result_flag = YES;

	}
}
- (void)saveImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect offest:(NSSize)offset imageFrame:(NSRect)frame
{
	[self _saveImage:cgimage withMouseCursorInRect:NSZeroRect offset:offset imageFrame:frame];
}

- (void)saveImage:(CGImageRef)cgimage imageFrame:(NSRect)image_frame
{
	[self _saveImage:cgimage withMouseCursorInRect:NSZeroRect offset:NSZeroSize imageFrame:image_frame];
}

- (void)saveImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect imageFrame:(NSRect)image_frame
{
	[self _saveImage:cgimage withMouseCursorInRect:rect offset:NSZeroSize imageFrame:image_frame];
}

- (void)saveImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect offset:(NSSize)offset imageFrame:(NSRect)image_frame
{
	[self _saveImage:cgimage withMouseCursorInRect:rect offset:offset imageFrame:image_frame];
}


- (void)saveImage:(CGImageRef)cgimage withMouseCursorInWindowList:(NSArray*)list imageFrame:(NSRect)frame
{
	NSRect all_rect = [Window unionNSRectWithWindowList:list];
	NSSize offset = [WindowShadow offset];

	if ([[UserDefaults valueForKey:UDKEY_WINDOW_SHADOW] boolValue]) {
		all_rect.origin.x -= offset.width;
		all_rect.origin.y -= offset.height;
	}
	[self saveImage:cgimage withMouseCursorInRect:all_rect offset:NSZeroSize imageFrame:all_rect];
}

// copy
- (void)copyImageWithBitmapImageRep:(NSBitmapImageRep*)bitmap_rep
{
	NSData* data = [bitmap_rep representationUsingType:NSTIFFFileType
											properties:[NSDictionary dictionary]];
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType]	owner:self];
	[pb setData:data forType:NSTIFFPboardType];
	// [data release];
	
	//	[self playSound];
	
}

- (void)copyImage:(CGImageRef)cgimage imageFrame:(NSRect)image_frame
{
	_copy_flag = YES;
	[self _saveImage:cgimage withMouseCursorInRect:NSZeroRect offset:NSZeroSize imageFrame:image_frame];
}

- (void)copyImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect imageFrame:(NSRect)image_frame
{
	_copy_flag = YES;
	[self _saveImage:cgimage withMouseCursorInRect:rect offset:NSZeroSize imageFrame:image_frame];
}

- (void)copyImage:(CGImageRef)cgimage withMouseCursorInWindowList:(NSArray*)list imageFrame:(NSRect)frame
{
	_copy_flag = YES;
	[self saveImage:cgimage withMouseCursorInWindowList:list imageFrame:frame];
}

- (void)copyImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect offset:(NSSize)offset imageFrame:(NSRect)frame
{
	_copy_flag = YES;
	[self _saveImage:cgimage withMouseCursorInRect:NSZeroRect offset:offset imageFrame:frame];
}

- (void)disableMouseEventInWindow
{
//	[_window setIgnoresMouseEvents:YES];
}

- (void)enableMouseEventInWindow
{
//	[_window setIgnoresMouseEvents:NO];
}


- (CGWindowID)windowID
{
	return (CGWindowID)[_window windowNumber];
}

- (CaptureView*)view
{
	return _view;
}
- (CaptureWindow*)window
{
	return _window;
}
- (Transition*)transition
{
	return _transition;
}
- (void)setMenuTitle:(NSString*)title
{
	[_app_controller setMenuTitle:title];
}

//
// Timer Dialog
//
- (void)startTimerOnClient:(id<TimerClient>)client title:(NSString*)title image:(NSImage*)image
{
	[self setContinouslyFlag:NO];
	[_timer_controller setTimerClient:client];
	[_timer_controller setTitle:title];
	[_timer_controller setImage:image];
	[_timer_controller showWindow];
	[_timer_controller start];
}

//
// for notification
//
- (void)screenChanged:(NSNotification *)notification
{
	NSRect frame = [[Screen defaultScreen] frame];
	[_window setFrame:frame display:NO];

	frame.origin = NSZeroPoint;
	[_view setFrame:frame];
}

- (void)resetSelection
{
	Handler* handler = [_handler_factory handlerWithName:CAPTURE_SELECTION];
	[handler reset];
}
- (void)openWindowConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	if (!view) {
		view = _view;
	}
	NSMenu* qc_menu = [_app_controller configMenu];
	[_current_handler setupQuickConfigMenu:qc_menu];
	[NSMenu popUpContextMenu:qc_menu withEvent:event forView:view];
}

- (void)openSelectionConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	if (!view) {
		view = _view;
	}
	NSMenu* qc_menu = [_app_controller selectionConfigMenu];
	[_current_handler setupQuickConfigMenu:qc_menu];
	[NSMenu popUpContextMenu:qc_menu withEvent:event forView:view];
}
- (void)openScreenConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	if (!view) {
		view = _view;
	}
	NSMenu* qc_menu = [_app_controller screenConfigMenu];
	[_current_handler setupQuickConfigMenu:qc_menu];
	[NSMenu popUpContextMenu:qc_menu withEvent:event forView:view];
}
- (void)openMenuConfigMenuWithView:(NSView*)view event:(NSEvent*)event
{
	if (!view) {
		view = _view;
	}
	NSMenu* qc_menu = [_app_controller menuConfigMenu];
	[_current_handler setupQuickConfigMenu:qc_menu];
	[NSMenu popUpContextMenu:qc_menu withEvent:event forView:view];
}

- (BOOL)isSameHandlerWhenPreviousCapture
{
	return (_current_handler == _previous_handler);
}

- (void)setContinouslyFlag:(BOOL)flag
{
	if (_continuous_flag != flag) {
		_continuous_flag = flag;
		[_file_manager setSerialFlag:flag];
	}
}

#pragma mark -
#pragma mark AppController Delegate
- (void)changedImageFormatTo:(int)image_format
{
	[_current_handler changedImageFormatTo:image_format];
	[_timer_controller changedImageFormatTo:image_format];
}

@end
