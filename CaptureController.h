//
//  DelegateWindow.h
//  SimpleCap
//
//  Created by - on 08/03/08.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileManager;
@class AppController;
@class CaptureView;
@class CaptureWindow;
@class Handler;
@class TimerController;
@class WindowShadow;
@class Screen;
@class Transition;
@class HandlerFactory;

@protocol TimerClient;
@interface CaptureController : NSObject {

	AppController*			_app_controller;
	FileManager*			_file_manager;
	CaptureView*			_view;
	CaptureWindow*			_window;
	HandlerFactory*			_handler_factory;
	

	Handler*				_current_handler;
	Handler*				_previous_handler;
	TimerController*		_timer_controller;
	
	Transition*				_transition;
	
	NSMenu*					_context_menu;
	
	BOOL					_result_flag;
	BOOL					_cancel_flag;
	BOOL					_copy_flag;
	BOOL					_continuous_flag;
}
- (id)initWithAppController:(AppController*)appController;
- (void)setFileManager:(FileManager*)fileManager;
- (void)startCaptureWithHandlerName:(NSString*)handlerName withObject:(id)object;

// for handlers
- (void)exit;
- (void)showResultMessage;
- (void)cancel;
- (AppController*)appController;
- (BOOL)isSameHandlerWhenPreviousCapture;
- (void)setContinouslyFlag:(BOOL)flag;
- (void)openViewerWithLastfile;

- (void)saveImage:(CGImageRef)cgimage imageFrame:(NSRect)frame;
- (void)saveImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect imageFrame:(NSRect)frame;
- (void)saveImage:(CGImageRef)cgimage withMouseCursorInWindowList:(NSArray*)list imageFrame:(NSRect)frame;
- (void)saveImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect offset:(NSSize)offset imageFrame:(NSRect)frame;

- (void)copyImageWithBitmapImageRep:(NSBitmapImageRep*)bitmap_rep;
- (void)copyImage:(CGImageRef)cgimage imageFrame:(NSRect)frame;
- (void)copyImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect imageFrame:(NSRect)frame;
- (void)copyImage:(CGImageRef)cgimage withMouseCursorInWindowList:(NSArray*)list imageFrame:(NSRect)frame;
- (void)copyImage:(CGImageRef)cgimage withMouseCursorInRect:(NSRect)rect offset:(NSSize)offset imageFrame:(NSRect)frame;

- (void)disableMouseEventInWindow;
- (void)enableMouseEventInWindow;


- (CGWindowID)windowID;

- (CaptureView*)view;
- (CaptureWindow*)window;
- (Transition*)transition;

- (void)setMenuTitle:(NSString*)title;

- (void)startTimerOnClient:(id<TimerClient>)client title:(NSString*)title image:(NSImage*)image;

- (void)openWindowConfigMenuWithView:(NSView*)view event:(NSEvent*)event;
- (void)openSelectionConfigMenuWithView:(NSView*)view event:(NSEvent*)event;
- (void)openScreenConfigMenuWithView:(NSView*)view event:(NSEvent*)event;
- (void)openMenuConfigMenuWithView:(NSView*)view event:(NSEvent*)event;

// for conroller
- (void)resetSelection;

// delegate
- (void)changedImageFormatTo:(int)image_format;

@end
