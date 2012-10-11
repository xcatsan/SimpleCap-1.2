//
//  PreferenceController.h
//  SimpleCap
//
//  Created by - on 08/09/12.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;
@class HotkeyRegister;
@class HotkeyTextView;
@interface PreferenceController : NSObject {

	IBOutlet NSWindow* _window;
	IBOutlet NSTabView* _tab_view;
	NSSize _window_size;
	
	IBOutlet NSImageView* _image_view;
	IBOutlet NSImageView* _selection_view;
	IBOutlet NSImageView* _screen_view;

	IBOutlet AppController* _app_controller;
	NSToolbar* _toolbar;
	NSArray* _toolbar_list;
	
	HotkeyRegister* _hotkey_register;
	IBOutlet HotkeyTextView* _hotkey_text;
	
	IBOutlet NSButton* _autostart_checkbox;
}

- (void)chooseImageLocation:(id)sender;

- (IBAction)clickImageOptions:(id)sender;
- (IBAction)clickSelectionOptions:(id)sender;
//- (IBAction)clickScreenOptions:(id)sender;
- (IBAction)chooseApplication:(id)sender;

- (IBAction)selectImageFormat:(id)sender;

- (void)openAtTabIndex:(NSInteger)tab_index;
- (void)setTabIndex:(NSInteger)tab_index;

- (void)registHotkeysFromDefaults;
- (IBAction)resetHotkey:(id)sender;

- (void)applicationWillTerminate;

- (IBAction)clickAutostartCheckbox:(id)sender;
- (void)enableLoginItem;
- (void)disableLoginItem;
- (BOOL)isEnableLoginItem;
- (void)updateToolbarOnGeneral;

@end
