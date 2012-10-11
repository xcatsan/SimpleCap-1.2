//
//  AppController.h
//  SimpleCap
//
//  Created by - on 08/03/02.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class FileManager;
@class CaptureController;
@class LauncedApplications;
@class FukidashiController;
@class PreferenceController;
@class SimpleViewerController;
enum {
	SCStateNormal,
	SCStateCapturing
};

@interface AppController : NSObject {

	NSStatusItem* _status_item;
	IBOutlet NSMenu* _status_menu;
	IBOutlet NSMenu *_app_menu;

	FileManager* _file_manager;
	CaptureController* _capture_controller;
	LauncedApplications* _launced_applications;
	
	NSImage*	_icon;
	NSImage*	_icon2;
	NSImage*	_icon3;

	int _state;
	
	BOOL _is_launched_dashboard;
	
	IBOutlet PreferenceController *_preference_controller;

	NSString* _capture_type;
	id _capture_option;
	
	FukidashiController* _fukidashi_controller;
	IBOutlet SimpleViewerController* _viewer_controller;
	
	BOOL _is_viewer_opened;
	
	// quick config menu
	IBOutlet NSMenu* _selection_config_menu;
	IBOutlet NSMenu* _config_menu;
	IBOutlet NSMenu* _menu_config_menu;
	IBOutlet NSMenu* _screen_config_menu;
	
}

- (void)setMenuTitle:(NSString*)title;
- (void)startCapture;
- (void)exitCaptureWithCancel:(BOOL)cancel_flag contiuous:(BOOL)contiuous_flag;

// menu actions
- (IBAction)captureSelection:(id)sender;
- (IBAction)captureWindow:(id)sender;
- (IBAction)captureTrackWindow:(id)sender;
- (IBAction)captureScreen:(id)sender;
- (IBAction)captureMenu:(id)sender;
//- (IBAction)captureApplication:(id)sender;
- (IBAction)captureWidget:(id)sender;
- (IBAction)cancelCapture:(id)sender;

- (IBAction)openPereferecesWindow:(id)sender;

- (IBAction)openSimpleViewer:(id)sender;
- (IBAction)openFolder:(id)sender;
- (IBAction)openHelp:(id)sender;
- (IBAction)resetSelection:(id)sender;

- (void)setIconStop;
- (void)setIconStart;

- (void)showMessage:(NSString*)message;

- (void)captureByLastHandler;
- (void)openFile:(NSString*)filename withApplication:(NSString*)path;

- (void)openViewerWithFile:(NSString*)filename;
- (void)openViewerWithLastfile;

- (SimpleViewerController*)viewerController;

- (FileManager*)fileManager;
- (void)copyImageWithBitmapImageRep:(NSBitmapImageRep*)bitmap_rep;

- (void)updateApplicationMenu:(NSMenu*)menu;

- (NSString*)captureType;

// context menu
- (NSMenu*)selectionConfigMenu;
- (NSMenu*)configMenu;
- (NSMenu*)screenConfigMenu;
- (NSMenu*)menuConfigMenu;

// for Context Menu (bindings)
- (BOOL)imageFormatPNG;
- (void)setImageFormatPNG:(BOOL)flag;
- (BOOL)imageFormatGIF;
- (void)setImageFormatGIF:(BOOL)flag;
- (BOOL)imageFormatJPEG;
- (void)setImageFormatJPEG:(BOOL)flag;
- (BOOL)imageFormatClipboard;
- (void)setImageFormatClipboard:(BOOL)flag;

@end
