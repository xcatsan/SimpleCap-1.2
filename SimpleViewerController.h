//
//  SimpleViewerController.h
//  SimpleCap
//
//  Created by - on 08/12/19.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ThinButtonBar;
@class SimpleViewerPanel;
@class SimpleViewerImageView;
@class SimpleViewerInfoView;
@class SimpleViewerBackgroundView;
@class AppController;
@class ApplicationMenu;
@class FilenameTextField;
@class ApplicationButtonPallete;
@interface SimpleViewerController : NSObject {

	IBOutlet AppController*		_app_controller;

	ThinButtonBar*		_button_bar;
	ThinButtonBar*		_button_bar2;
	ApplicationButtonPallete* _app_pallete;

	SimpleViewerPanel*			_panel;
	SimpleViewerImageView*		_image_view;
	SimpleViewerInfoView*		_info_view;
	SimpleViewerBackgroundView*	_background_view;
	
	NSString*	_filename;
	NSDate*		_file_lastmodified;
	BOOL _is_init_panel_position;

	ApplicationMenu* _app_menu;
	
	FilenameTextField* _filename_textfiled;
	
	IBOutlet NSMenu* _capture_menu;
	IBOutlet NSMenu* _capture_app_menu;
	
	IBOutlet NSMenu* _config_menu;
	IBOutlet NSMenu* _context_menu;
	IBOutlet NSMenu* _operation_menu;
	
	FSEventStreamRef _fsevent_stream;
}

- (void)close;
- (void)show;
- (BOOL)isOpened;
- (NSString*)filename;

- (void)openWithFile:(NSString*)filename isNew:(BOOL)new_flag;
- (void)showFile:(NSString*)filename isFitToImage:(BOOL)is_fit withDirection:(int)direction;

- (void)flagsChanged:(NSEvent *)theEvent;

- (CGFloat)reductionRatio;
- (NSBitmapImageRep*)currentBitmapImageRepIsReduction:(BOOL)is_reduction;
- (void)keyDown:(id)theEvent;

- (void)endEditFilenameIsCancel:(BOOL)is_cancel;

// delegate methods
// clickedSimpleViewerAtTag:withFilename:

// for SimpleViewerImageView
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void)copyFileTo:(NSURL*)dst_url;

// for IB
- (IBAction)clickedCopy:(id)sender;
- (IBAction)clickedMoveToTrash:(id)sender;
- (IBAction)clickedSave:(id)sender;
- (IBAction)clickedPrevious:(id)sender;
- (IBAction)clickedNext:(id)sender;
- (IBAction)clickedCaptureAgain:(id)sender;
- (IBAction)clickedRetake:(id)sender;
- (IBAction)clickedOpenWithApplication:(id)sender;
- (IBAction)clickedDuplicate:(id)sender;

// for Context Menu (bindings)
- (BOOL)backgroundBlack;
- (void)setBackgroundBlack:(BOOL)flag;
- (BOOL)backgroundWhite;
- (void)setBackgroundWhite:(BOOL)flag;
- (BOOL)backgroundCheckboard;
- (void)setBackgroundCheckboard:(BOOL)flag;

// for File management
-(BOOL)updateOpendFile;

@end
