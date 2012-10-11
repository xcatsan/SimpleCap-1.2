//
//  AppController.m
//  SimpleCap
//
//  Created by - on 08/03/02.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "FileManager.h"
#import "CaptureController.h"
#import "LaunchedApplications.h"
#import "UserDefaults.h"
#import "FukidashiController.h"
#import "Window.h"
#import "PreferenceController.h"
#import "SimpleViewerController.h"
#import "CaptureType.h"
#import "Screen.h"
#import "Hotkey.h"
#import "ImageFormat.h"

#define SC_HOTKEY_SIGNATURE	'schk'
#define SC_MENUTAG_APPLICATION 201

@implementation AppController

//-------------------------
// Initialize
//-------------------------
+ (void)initialize
{
	[UserDefaults setup];
}

- (id)init
{
	if (self = [super init]) {
		_state = SCStateNormal;
		_file_manager = [[FileManager alloc] init];
		_capture_controller = [[CaptureController alloc] initWithAppController:self];
		_launced_applications = [[LaunchedApplications alloc] initWithDelegate:self];
		[_capture_controller setFileManager:_file_manager];
		_icon = [[NSImage imageNamed:@"status_bar_icon"] retain];
		_icon2 = [[NSImage imageNamed:@"status_bar_icon2"] retain];
		_icon3 = [[NSImage imageNamed:@"status_bar_icon3"] retain];
		_fukidashi_controller = [FukidashiController sharedConroller];
	}
	return self;
}

- (void) dealloc
{
	[_icon release];
	[_icon2 release];
	[_icon3 release];
	[_file_manager release];
	[_capture_controller release];
	[_launced_applications release];
	[_viewer_controller release];
	[super dealloc];
}

-(void)awakeFromNib
{
	[_app_menu setDelegate:self];
}


- (void)setCaptureType:(NSString*)capture_type
{
	_capture_type = capture_type;
	
}
- (NSString*)captureType
{
	return _capture_type;
}


//=========================
// Applicatin Menu handler
//=========================
- (void)updateApplicationMenu:(NSMenu*)menu
{
	[_launced_applications updateApplicationMenu:menu];
}

- (void)menuWillOpen:(NSMenu *)menu
{
	if (menu == _app_menu) {
		[self updateApplicationMenu:_app_menu];
	}
}

- (void)selectApplication:(id)sender
{
	_state = SCStateCapturing;
	[self setCaptureType:CAPTURE_APPLICATION];

	if (sender) {
		id tmp_obj = [[sender representedObject] retain];
		[_capture_option release];
		_capture_option = tmp_obj;
	};

	if (_capture_option) {
		[_capture_controller startCaptureWithHandlerName:CAPTURE_APPLICATION
											  withObject:_capture_option];
	}
}

- (void)openMenu
{
	[_status_item popUpStatusItemMenu:_status_menu];
}

- (void)hotkeyDown:(Hotkey*)hotkey
{
	if ([[UserDefaults valueForKey:UDKEY_HOT_KEY_ENABLE] boolValue]) {
		[self openMenu];
	}
}

//=========================
// NApplication Deleagetes
//=========================
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	//------------------
	// setup status bar
	//------------------
	NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
	
	_status_item = [status_bar statusItemWithLength:NSVariableStatusItemLength];
	[_status_item retain];
	[_status_item setTitle:@""];

	[self setIconStop];
	[_status_item setAlternateImage:_icon2];
	[_status_item setHighlightMode:YES];
	[_status_item setMenu:_status_menu];


	//------------------
	// setup hot key
	//------------------
	[_preference_controller registHotkeysFromDefaults];
}

- (void)setMenuTitle:(NSString*)title
{
	[_status_item setTitle:title];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
	[_preference_controller applicationWillTerminate];
}

- (void)startCapture
{
	[self setIconStart];
	_is_viewer_opened = [_viewer_controller isOpened];
	[_viewer_controller close];
	[[_status_menu itemWithTag:SC_MENUTAG_APPLICATION] setEnabled:NO];
}

- (void)exitCaptureWithCancel:(BOOL)cancel_flag contiuous:(BOOL)contiuous_flag
{
	if (_is_launched_dashboard) {
		if ([[NSWorkspace sharedWorkspace]
			 launchAppWithBundleIdentifier:@"com.apple.dock"
			 options:0 additionalEventParamDescriptor:nil launchIdentifier:nil]) {
		} else {
		}
		_is_launched_dashboard = NO;
	}
	[self setIconStop];
	[[_status_menu itemWithTag:SC_MENUTAG_APPLICATION] setEnabled:YES];
	_state = SCStateNormal;
	
	if (cancel_flag) {
		if (contiuous_flag) {
			NSString* filename = [_file_manager lastFilename];
			[_viewer_controller openWithFile:filename isNew:NO];
		} else if (_is_viewer_opened) {
			[_viewer_controller show];
		}
	}
}

//=========================
// Menu actions
//=========================
- (IBAction)captureSelection:(id)sender
{
	_state = SCStateCapturing;
	[self setCaptureType:CAPTURE_SELECTION];
	[_capture_controller startCaptureWithHandlerName:CAPTURE_SELECTION withObject:nil];
}

- (IBAction)captureWindow:(id)sender
{
	_state = SCStateCapturing;
	[self setCaptureType:CAPTURE_WINDOW];
	[_capture_controller startCaptureWithHandlerName:CAPTURE_WINDOW withObject:nil];
}

- (IBAction)captureTrackWindow:(id)sender
{
	_state = SCStateCapturing;
	[self setCaptureType:CAPTURE_TRACKWINDOW];
	[_capture_controller startCaptureWithHandlerName:CAPTURE_TRACKWINDOW withObject:nil];
}

- (IBAction)captureScreen:(id)sender
{
	_state = SCStateCapturing;
	[self setCaptureType:CAPTURE_SCREEN];
	[_capture_controller startCaptureWithHandlerName:CAPTURE_SCREEN withObject:nil];
}

- (IBAction)captureMenu:(id)sender
{
	_state = SCStateCapturing;
	[self setCaptureType:CAPTURE_MENU];
	[_capture_controller startCaptureWithHandlerName:CAPTURE_MENU withObject:nil];
}

- (IBAction)captureWidget:(id)sender
{
	if ([[NSWorkspace sharedWorkspace]
		launchAppWithBundleIdentifier:@"com.apple.dashboardlauncher"
		 options:0 additionalEventParamDescriptor:nil launchIdentifier:nil]) {
		_is_launched_dashboard = YES;
		_state = SCStateCapturing;
		[self setCaptureType:CAPTURE_WIDGET];

		[NSThread sleepForTimeInterval:1.0];
		[_capture_controller startCaptureWithHandlerName:CAPTURE_WIDGET withObject:nil];
	} else {
		NSLog(@"Can not launce Dashboard.app");
	}
}

/*
 * NOTE: see "selectApplicationMenu:"
- (IBAction)captureApplication:(id)sender
{
	_state = SCStateCapturing;
	[_capture_controller startCaptureWithHandlerName:@"Application"];
}
*/

 -(BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
	if (@selector(cancelCapture:) == [menuItem action]) {
		if (_state == SCStateCapturing) {
			return YES;
		} else {
			return NO;
		}
	}
	if (_state == SCStateNormal) {
		return YES;
	}
	if (@selector(openPereferecesWindow:) == [menuItem action]) {
		return YES;
	}
	if (@selector(resetSelection:) == [menuItem action]) {
		return YES;
	}
	
	if (@selector(setImageFormatPNG:) == [menuItem action] ||
		@selector(setImageFormatGIF:) == [menuItem action] ||
		@selector(setImageFormatJPEG:) == [menuItem action] ) {
		return YES;
	}
	
	return NO;
}

- (void)setIconStop
{
	[_status_item setImage:_icon];
}
- (void)setIconStart
{
	[_status_item setImage:_icon3];
}

- (IBAction)cancelCapture:(id)sender
{
	[_capture_controller cancel];
}

- (IBAction)openPereferecesWindow:(id)sender
{
	NSInteger tab_index = -1;
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		id rep_obj = [sender representedObject];
		if (rep_obj) {
			tab_index = [rep_obj intValue];
		}
	}
	[_preference_controller openAtTabIndex:tab_index];
	/*
	if (![NSApp isActive]) {
		[_viewer_controller close];
		[NSApp activateIgnoringOtherApps:YES];
	}
	 */
}

- (IBAction)openFolder:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[UserDefaults valueForKey:UDKEY_IMAGE_LOCATION]];
}

- (IBAction)openHelp:(id)sender
{
	NSURL *url = [NSURL URLWithString:NSLocalizedString(@"URLHelp", @"")];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)showMessage:(NSString*)message
{
	[_fukidashi_controller showMessage:message];
}

- (void)copyImageWithBitmapImageRep:(NSBitmapImageRep*)bitmap_rep
{
	[_capture_controller copyImageWithBitmapImageRep:bitmap_rep];
}

//=========================
// For Viewer
//=========================
- (void)captureByLastHandler
{
	if ([_capture_type isEqualToString:CAPTURE_WINDOW]) {
		[self captureWindow:nil];
		
	} else if ([_capture_type isEqualToString:CAPTURE_TRACKWINDOW]) {
		[self captureTrackWindow:nil];
		
	} else if ([_capture_type isEqualToString:CAPTURE_SELECTION]) {
		[self captureSelection:nil];
		
	} else if ([_capture_type isEqualToString:CAPTURE_SCREEN]) {
		[self captureScreen:nil];
		
	} else if ([_capture_type isEqualToString:CAPTURE_MENU]) {
		[self captureMenu:nil];
		
	} else if ([_capture_type isEqualToString:CAPTURE_APPLICATION]) {
		[self selectApplication:nil];
		
	} else if ([_capture_type isEqualToString:CAPTURE_WIDGET]) {
		[self captureWidget:nil];
	} else {
		// default
		[self captureSelection:nil];
	}
	
}


- (void)openFile:(NSString*)filename withApplication:(NSString*)path
{
	if ([[NSFileManager defaultManager] isReadableFileAtPath:filename]) {
		[[NSWorkspace sharedWorkspace] openFile:filename withApplication:path];
	} else {
		[[FukidashiController sharedConroller] showMessage:NSLocalizedString(@"FileNotFound", @"")];
	}
	
}

- (SimpleViewerController*)viewerController
{
	return _viewer_controller;
}


- (void)openViewerWithFile:(NSString*)filename
{
	[_file_manager lastFilename];	// only to update directory info
	[_viewer_controller openWithFile:filename isNew:YES];
}
- (void)openViewerWithLastfile
{
	if (![_viewer_controller isOpened]) {
		NSString* filename = [_file_manager lastFilename];
		[_viewer_controller openWithFile:filename isNew:YES];
	}
}

- (IBAction)openSimpleViewer:(id)sender
{
	NSString* filename = [_file_manager lastFilename];
	[_viewer_controller openWithFile:filename isNew:NO];
}

- (IBAction)resetSelection:(id)sender
{
	[_capture_controller resetSelection];
	[_fukidashi_controller showMessage:NSLocalizedString(@"ResetSelection", @"")];
}


- (FileManager*)fileManager
{
	return _file_manager;
}

- (NSMenu*)selectionConfigMenu
{
	return _selection_config_menu;
}
- (NSMenu*)configMenu
{
	return _config_menu;
}

- (NSMenu*)screenConfigMenu
{
	return _screen_config_menu;
}

- (NSMenu*)menuConfigMenu
{
	return _menu_config_menu;
}


// for Context Menu (bindings)
- (BOOL)imageFormatPNG
{
	return ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_PNG);
}

- (void)setImageFormatPNG:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:IMAGEFORMAT_PNG] forKey:UDKEY_IMAGE_FORMAT];
		[self setImageFormatGIF:NO];
		[self setImageFormatJPEG:NO];
		[self setImageFormatClipboard:NO];
		[UserDefaults save];
		[_capture_controller changedImageFormatTo:IMAGEFORMAT_PNG];
	} else if ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_PNG) {
		[self setImageFormatGIF:YES];
	}
}

- (BOOL)imageFormatGIF
{
	return ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_GIF);
}

- (void)setImageFormatGIF:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:IMAGEFORMAT_GIF] forKey:UDKEY_IMAGE_FORMAT];
		[self setImageFormatPNG:NO];
		[self setImageFormatJPEG:NO];
		[self setImageFormatClipboard:NO];
		[UserDefaults save];
		[_capture_controller changedImageFormatTo:IMAGEFORMAT_GIF];
	} else if ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_GIF) {
		[self setImageFormatJPEG:YES];
	}
}

- (BOOL)imageFormatJPEG
{
	return ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_JPEG);
}

- (void)setImageFormatJPEG:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:IMAGEFORMAT_JPEG] forKey:UDKEY_IMAGE_FORMAT];
		[self setImageFormatGIF:NO];
		[self setImageFormatPNG:NO];
		[self setImageFormatClipboard:NO];
		[UserDefaults save];
		[_capture_controller changedImageFormatTo:IMAGEFORMAT_JPEG];
	} else if ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_JPEG) {
		[self setImageFormatClipboard:YES];
	}
}
- (BOOL)imageFormatClipboard
{
	return ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_CLIPBOARD);
}

- (void)setImageFormatClipboard:(BOOL)flag
{
	if (flag) {
		[UserDefaults setValue:[NSNumber numberWithInt:IMAGEFORMAT_CLIPBOARD] forKey:UDKEY_IMAGE_FORMAT];
		[self setImageFormatGIF:NO];
		[self setImageFormatPNG:NO];
		[self setImageFormatJPEG:NO];
		[UserDefaults save];
		[_capture_controller changedImageFormatTo:IMAGEFORMAT_CLIPBOARD];
	} else if ([[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue] == IMAGEFORMAT_CLIPBOARD) {
		[self setImageFormatPNG:YES];
	}
}
@end
