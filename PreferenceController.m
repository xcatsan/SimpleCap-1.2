//
//  PreferenceController.m
//  SimpleCap
//
//  Created by - on 08/09/12.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "PreferenceController.h"
#import "UserDefaults.h"
#import "AppController.h"
#import "HotkeyRegister.h"
#import "HotkeyTextView.h"
#import "Hotkey.h"
#import "ImageFormat.h"

#define PREFERENCE_TOOLBAR	@"PREFERENCE_TOOLBAR"
#define TOOLBAR_GENERAL		@"TOOLBAR_GENERAL"
#define	TOOLBAR_WINDOWS		@"TOOLBAR_WINDOWS"
#define	TOOLBAR_SELECTION	@"TOOLBAR_SELECTION"
#define TOOLBAR_ADVANCED	@"TOOLBAR_ADVANCED"
#define TOOLBAR_VIEWER		@"TOOLBAR_VIEWER"
//#define TOOLBAR_SCREEN		@"TOOLBAR_SCREEN"

#define TAG_MOUSE_CURSOR	10
#define TAG_WINDOW_SHADOW	11
#define TAG_BACKGOND		12

#define TAG_SELECTION_FRMAE		20
#define TAG_SELECTION_SHADOW	21
#define TAG_SELECTION_ROUNDRECT	22

@implementation PreferenceController

-(id)init
{
	self = [super init];
	if (self) {
		_toolbar_list = [[NSArray arrayWithObjects:
						  TOOLBAR_GENERAL,
						  TOOLBAR_WINDOWS,
						  TOOLBAR_SELECTION,
						  TOOLBAR_VIEWER,
//						  TOOLBAR_SCREEN,
						  TOOLBAR_ADVANCED,
						  nil] retain];

	}
	return self;
}
- (void) dealloc
{
	[_toolbar_list release];
	[_toolbar release];
	[super dealloc];
}

//<<--------------------------------

- (void)drawOutputExample
{
	NSSize frame_size = [_image_view frame].size;
	NSImage* frame_image = [[[NSImage alloc] initWithSize:frame_size] autorelease];
	NSImage* example_image = [NSImage imageNamed:@"output_example"];
	NSSize example_image_size = [example_image size];
	NSPoint draw_point = NSMakePoint(8-36, frame_size.height - example_image_size.height-8+37);

	[frame_image lockFocus];

	// Background
	if ([[UserDefaults valueForKey:UDKEY_BACKGROUND] boolValue]) {
		[[NSImage imageNamed:@"output_background"] compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	}
	[NSGraphicsContext saveGraphicsState];

	// Window Shadow
	if ([[UserDefaults valueForKey:UDKEY_WINDOW_SHADOW] boolValue]) {

		NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(10.0, -10.0)];
		[shadow setShadowBlurRadius:10.0];
		[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
		[shadow set];

	}
	// Compsite Image
	[example_image compositeToPoint:draw_point operation:NSCompositeSourceOver];

	[NSGraphicsContext restoreGraphicsState];
	
	// Mouse Cursor
	if ([[UserDefaults valueForKey:UDKEY_MOUSE_CURSOR] boolValue]) {
		NSPoint cursor_point = NSMakePoint(50, 50);
		[[[NSCursor arrowCursor] image] compositeToPoint:cursor_point operation:NSCompositeSourceOver];
	}
	
	[frame_image unlockFocus];
	[_image_view setImage:frame_image];
}

- (IBAction)clickImageOptions:(id)sender
{
	[self drawOutputExample];
}

#define WHITE_FRAME_WIDTH	3.0
#define WHITE_FRAME_HEIGHT	3.0
#define ROUND_RECT_RADIUS	7.0
- (void)drawSelectionExample
{
	BOOL is_roundrect = [[UserDefaults valueForKey:UDKEY_SELECTION_ROUND_RECT] boolValue];
	BOOL is_white_frame = [[UserDefaults valueForKey:UDKEY_SELECTION_WHITE_FRAME] boolValue];
	BOOL is_exclude_desktop_icons = [[UserDefaults valueForKey:UDKEY_SELECTION_EXCLUDE_ICONS] boolValue];
	
	NSSize frame_size = [_image_view frame].size;
	NSImage* frame_image = [[[NSImage alloc] initWithSize:frame_size] autorelease];
	
	NSString* example_image_name;
	if (is_exclude_desktop_icons) {
		example_image_name = @"selection_example2";
	} else {
		example_image_name = @"selection_example";
	}
	NSImage* example_image = [NSImage imageNamed:example_image_name];
	NSSize example_image_size = [example_image size];
	NSPoint draw_point = NSMakePoint((frame_size.width - example_image_size.width)/2, (frame_size.height - example_image_size.height)/2);

	CGFloat frame_width = 0.0;
	CGFloat frame_height = 0.0;
	if (is_white_frame) {
		frame_width = WHITE_FRAME_WIDTH;
		frame_height = WHITE_FRAME_HEIGHT;
	}

	NSRect wf_rect = NSMakeRect(draw_point.x-frame_width,
								draw_point.y-frame_height,
								example_image_size.width + frame_width*2,
								example_image_size.height + frame_height*2);

	NSRect img_rect = NSMakeRect(draw_point.x,
								 draw_point.y,
								 example_image_size.width,
								 example_image_size.height);

	NSRect wf_rect_inner = img_rect;
	
	NSRect view_rect = NSMakeRect(0,
								  0,
								  frame_size.width,
								  frame_size.height);

	NSBezierPath* round;
	NSBezierPath* frame;
	NSBezierPath* frame_inner;
	if (is_roundrect) {
		round = [NSBezierPath bezierPathWithRoundedRect:img_rect
												xRadius:ROUND_RECT_RADIUS-2.0
												yRadius:ROUND_RECT_RADIUS-2.0];

		frame = [NSBezierPath bezierPathWithRoundedRect:wf_rect
												xRadius:ROUND_RECT_RADIUS
												yRadius:ROUND_RECT_RADIUS];
		
		frame_inner = [NSBezierPath bezierPathWithRoundedRect:wf_rect_inner
												xRadius:ROUND_RECT_RADIUS-2.0
												yRadius:ROUND_RECT_RADIUS-2.0];
	} else {
		frame = [NSBezierPath bezierPathWithRect:wf_rect];
		frame_inner = [NSBezierPath bezierPathWithRect:wf_rect_inner];
	}

	[frame_image lockFocus];

	[[NSColor lightGrayColor] set];
	NSRectFill(view_rect);
	[[NSColor darkGrayColor] set];
	NSFrameRectWithWidth(NSMakeRect(0.5,
									0.5,
									view_rect.size.width-1,
									view_rect.size.height-1), 0.5);

	[NSGraphicsContext saveGraphicsState];

	// Selection Shadow
	if ([[UserDefaults valueForKey:UDKEY_SELECTION_SHADOW] boolValue]) {
		NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(5.0, -5.0)];
		[shadow setShadowBlurRadius:10.0];
		[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
		[shadow set];
	}
	
	// White Frame
	[[NSColor whiteColor] set];
	[frame fill];
	
	
	[NSGraphicsContext restoreGraphicsState];

	// Compsite Image
	if (is_roundrect) {
		[round setClip];
	}

	[example_image compositeToPoint:draw_point operation:NSCompositeSourceOver];

	if (is_white_frame) {
		[[NSColor blackColor] set];
		[frame_inner setLineWidth:0.25];
		[frame_inner stroke];
	}

	// Mouse Cursor
	if ([[UserDefaults valueForKey:UDKEY_MOUSE_CURSOR] boolValue]) {
		NSPoint cursor_point = NSMakePoint(65, 25);
		[[[NSCursor arrowCursor] image] compositeToPoint:cursor_point operation:NSCompositeSourceOver];
	}
	
	[frame_image unlockFocus];
	[_selection_view setImage:frame_image];
	
}

/*
- (void)drawScreenExample
{
	BOOL is_exclude_desktop_icons = [[UserDefaults valueForKey:UDKEY_SCREEN_EXCLUDE_ICONS] boolValue];
	
	NSSize frame_size = [_screen_view frame].size;
	NSImage* frame_image = [[[NSImage alloc] initWithSize:frame_size] autorelease];
	
	NSString* example_image_name;
	if (is_exclude_desktop_icons) {
		example_image_name = @"selection_example2";
	} else {
		example_image_name = @"selection_example";
	}
	NSImage* example_image = [NSImage imageNamed:example_image_name];
	NSSize example_image_size = [example_image size];
	NSPoint draw_point = NSMakePoint((frame_size.width - example_image_size.width)/2, (frame_size.height - example_image_size.height)/2);
	[frame_image lockFocus];
	[example_image compositeToPoint:draw_point operation:NSCompositeSourceOver];
	[frame_image unlockFocus];
	[_screen_view setImage:frame_image];
}

*/

- (IBAction)clickSelectionOptions:(id)sender
{
	[self drawSelectionExample];
}
/*
- (IBAction)clickScreenOptions:(id)sender
{
	[self drawScreenExample];
}
 */

#define SC_MARGIN_BOTTOM	10
- (void)updateWindow
{
	NSTabViewItem *item = [_tab_view selectedTabViewItem];
	NSArray* subviews = [[item view] subviews];
	
	NSRect view_frame = NSZeroRect;
	
	for (NSView* view in subviews) {
		view_frame = NSUnionRect(view_frame, [view frame]);
	}
	
	NSRect window_frame = [_window frame];
	
	CGFloat diff_y = view_frame.origin.y - SC_MARGIN_BOTTOM;
	
	CGFloat origin_y = window_frame.origin.y + window_frame.size.height;
	
	window_frame.size.height = _window_size.height - diff_y;
	window_frame.origin.y = origin_y - window_frame.size.height;
	
	
	//	[_window setFrame:window_frame display:YES animate:YES];
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:_window	forKey:NSViewAnimationTargetKey];
	[dict setObject:[NSValue valueWithRect:[_window frame]]
			 forKey:NSViewAnimationStartFrameKey];
	[dict setObject:[NSValue valueWithRect:window_frame]
			 forKey:NSViewAnimationEndFrameKey];
	NSViewAnimation* anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:0.25];
	[anim setDelegate:self];
	[anim startAnimation];
	[anim release];
	
}


- (void)awakeFromNib
{
	_hotkey_register = [HotkeyRegister sharedRegister];
	
	_toolbar = [[NSToolbar alloc] initWithIdentifier:PREFERENCE_TOOLBAR];
	[_toolbar setDelegate:self];
	[_window setToolbar:_toolbar];
	[_toolbar setSelectedItemIdentifier:TOOLBAR_GENERAL];
	[_window setTitle:NSLocalizedString(@"General", @"")];
	
	[self drawOutputExample];
	[self drawSelectionExample];
	
	_window_size = [_window frame].size;
	[self updateWindow];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *toolbar_item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];

	if ([itemIdentifier isEqualToString:TOOLBAR_GENERAL]) {
		[toolbar_item setLabel:NSLocalizedString(@"PreferenceGeneral", @"")];
		[toolbar_item setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
		[toolbar_item setTarget:self];
		[toolbar_item setAction:@selector(click:)];
	
	} else if ([itemIdentifier isEqualToString:TOOLBAR_WINDOWS]) {
			[toolbar_item setLabel:NSLocalizedString(@"PreferenceOutputOptions", @"")];
			[toolbar_item setImage:[NSImage imageNamed:NSImageNameAdvanced]];
			[toolbar_item setTarget:self];
			[toolbar_item setAction:@selector(click:)];

	} else if ([itemIdentifier isEqualToString:TOOLBAR_SELECTION]) {
		[toolbar_item setLabel:NSLocalizedString(@"PreferenceSelectionOptions", @"")];
		[toolbar_item setImage:[NSImage imageNamed:@"toolbar_selection"]];
		[toolbar_item setTarget:self];
		[toolbar_item setAction:@selector(click:)];

	} else if ([itemIdentifier isEqualToString:TOOLBAR_VIEWER]) {
		[toolbar_item setLabel:NSLocalizedString(@"PreferenceViewer", @"")];
		[toolbar_item setImage:[NSImage imageNamed:@"toolbar_viewer"]];
		[toolbar_item setTarget:self];
		[toolbar_item setAction:@selector(click:)];

		/*
	} else if ([itemIdentifier isEqualToString:TOOLBAR_SCREEN]) {
		[toolbar_item setLabel:NSLocalizedString(@"PreferenceScreen", @"")];
		[toolbar_item setImage:[NSImage imageNamed:@"toolbar_viewer"]];
		[toolbar_item setTarget:self];
		[toolbar_item setAction:@selector(click:)];
		*/
	} else if ([itemIdentifier isEqualToString:TOOLBAR_ADVANCED]) {
		[toolbar_item setLabel:NSLocalizedString(@"PreferenceMouseCursor", @"")];
		[toolbar_item setImage:[NSImage imageNamed:@"toolbar_cursor"]];
		[toolbar_item setTarget:self];
		[toolbar_item setAction:@selector(click:)];
		
	} else {
		toolbar_item = nil;
	}

	return toolbar_item;
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return _toolbar_list;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return _toolbar_list;
}

- (void)click:(id)sender
{
	[_window setTitle:[sender label]];

	NSString* item_identifier = [sender itemIdentifier];

	NSInteger index = 0;
	if ([item_identifier isEqualToString:TOOLBAR_GENERAL]) {
		index = 0;
		[self updateToolbarOnGeneral];
	} else if ([item_identifier isEqualToString:TOOLBAR_WINDOWS]) {
		[self drawOutputExample];
		index = 1;
	} else if ([item_identifier isEqualToString:TOOLBAR_SELECTION]) {
		[self drawSelectionExample];
		index = 2;
	} else if ([item_identifier isEqualToString:TOOLBAR_VIEWER]) {
		index = 3;
		/*
	} else if ([item_identifier isEqualToString:TOOLBAR_SCREEN]) {
		[self drawScreenExample];
		index = 4;
		 */
	} else if ([item_identifier isEqualToString:TOOLBAR_ADVANCED]) {
		index = 4;
	}
	[_tab_view selectTabViewItemAtIndex:index];

}

-(NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
	return _toolbar_list;
}


- (void)chooseImageLocation:(id)sender
{
	NSString* path = [UserDefaults valueForKey:UDKEY_IMAGE_LOCATION];
	
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];

	int result = [openPanel runModalForDirectory:path
									 file:nil
									types:nil];

	if (result == NSOKButton) {
		NSArray* filenames = [openPanel filenames];
		if ([filenames count] > 0) {
			NSString* new_path = [filenames objectAtIndex:0];
			[UserDefaults setValue:new_path forKey:UDKEY_IMAGE_LOCATION];
			[UserDefaults save];
		}
	}
}

- (void)setTabIndex:(NSInteger)tab_index
{
	switch (tab_index) {
		case 0:
			[_tab_view selectTabViewItemAtIndex:tab_index];
			[_toolbar setSelectedItemIdentifier:TOOLBAR_GENERAL];
			break;

		case 1:
			[_tab_view selectTabViewItemAtIndex:tab_index];
			[_toolbar setSelectedItemIdentifier:TOOLBAR_WINDOWS];
			break;
			
		case 2:
			[_tab_view selectTabViewItemAtIndex:tab_index];
			[_toolbar setSelectedItemIdentifier:TOOLBAR_SELECTION];
			break;
			
		case 3:
			[_tab_view selectTabViewItemAtIndex:tab_index];
			[_toolbar setSelectedItemIdentifier:TOOLBAR_VIEWER];
			break;
			
			/*
		case 4:
			[_tab_view selectTabViewItemAtIndex:tab_index];
			[_toolbar setSelectedItemIdentifier:TOOLBAR_SCREEN];
			break;
			*/
			
		case 4:
			[_tab_view selectTabViewItemAtIndex:tab_index];
			[_toolbar setSelectedItemIdentifier:TOOLBAR_ADVANCED];
			break;
			
		default:
			break;
	}
}
- (void)openAtTabIndex:(NSInteger)tab_index
{
	[self setTabIndex:tab_index];
	[NSApp activateIgnoringOtherApps:YES];
	[_window makeKeyAndOrderFront:self];
//	[_window orderWindow:NSWindowAbove relativeTo:0];
}

- (BOOL)animationShouldStart:(NSAnimation *)animation
{
	[[[_tab_view selectedTabViewItem] view] setHidden:YES];
	return YES;
}
- (void)animationDidEnd:(NSAnimation *)animation
{
	[[[_tab_view selectedTabViewItem] view] setHidden:NO];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self updateWindow];
}

- (IBAction)chooseApplication:(id)sender
{
	NSString* app;
	int tag = [sender tag];
	
	switch (tag) {
		case 1:
			app = [UserDefaults valueForKey:UDKEY_APPLICATION1];
			break;
		case 2:
			app = [UserDefaults valueForKey:UDKEY_APPLICATION2];
			break;
		case 3:
			app = [UserDefaults valueForKey:UDKEY_APPLICATION3];
			break;
		case 4:
			app = [UserDefaults valueForKey:UDKEY_APPLICATION4];
			break;
		case 5:
			app = [UserDefaults valueForKey:UDKEY_APPLICATION5];
			break;
	}
	
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanCreateDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	
	NSString* title = NSLocalizedString(@"PreferenceRemoveApplication", @"");
	NSRect rect = NSZeroRect;
	rect.size = [title sizeWithAttributes:[NSDictionary dictionary]];
	rect.size.width += 20;
	NSButton* check_box =
		[[[NSButton alloc] initWithFrame:rect] autorelease];
	[check_box setButtonType:NSSwitchButton];
	[check_box setTitle:title];
	[openPanel setAccessoryView:check_box];
	
	NSArray* file_types = [NSArray arrayWithObject:@"app"];
	
	int result = [openPanel runModalForDirectory:[app stringByDeletingLastPathComponent]
											file:[app lastPathComponent]
										   types:file_types];
	
	NSString* new_app = nil;
	if (result == NSOKButton) {

		if ([check_box intValue] == 0) {
			NSArray* filenames = [openPanel filenames];
			if ([filenames count] > 0) {
				new_app = [filenames objectAtIndex:0];
			}
		}
		switch (tag) {
			case 1:
				[UserDefaults setValue:new_app forKey:UDKEY_APPLICATION1];
				break;
			case 2:
				[UserDefaults setValue:new_app forKey:UDKEY_APPLICATION2];
				break;
			case 3:
				[UserDefaults setValue:new_app forKey:UDKEY_APPLICATION3];
				break;
			case 4:
				[UserDefaults setValue:new_app forKey:UDKEY_APPLICATION4];
				break;
			case 5:
				[UserDefaults setValue:new_app forKey:UDKEY_APPLICATION5];
				break;
		}
		[UserDefaults save];
	}
}

- (IBAction)selectImageFormat:(id)sender
{
	switch ([[sender selectedItem] tag]) {
		case IMAGEFORMAT_PNG:
			[_app_controller setImageFormatPNG:YES];
			break;
		case IMAGEFORMAT_GIF:
			[_app_controller setImageFormatGIF:YES];
			break;
		case IMAGEFORMAT_JPEG:
			[_app_controller setImageFormatJPEG:YES];
			break;
		case IMAGEFORMAT_CLIPBOARD:
			[_app_controller setImageFormatClipboard:YES];
			break;
	}
}

- (void)registHotkeysFromDefaults
{
	NSNumber* number;
	Hotkey *hotkey;
	
	number = [UserDefaults valueForKey:UDKEY_HOT_KEY];
	hotkey = [[[Hotkey alloc] initWithSavekey:UDKEY_HOT_KEY
									   number:number
									   target:_app_controller] autorelease];
	[_hotkey_register registHotkey:hotkey];
	
	_hotkey_text.hotkey = hotkey;
	_hotkey_text.target = self;
	
}

- (BOOL)hotkeyShouldChange:(Hotkey*)hotkey
{
	[_hotkey_register registHotkey:hotkey];
	[UserDefaults setValue:[hotkey numberValue] forKey:UDKEY_HOT_KEY];
	[UserDefaults save];

	return YES;
}

- (IBAction)resetHotkey:(id)sender
{
	[_hotkey_register unregistAll];
	[UserDefaults resetValueForKey:UDKEY_HOT_KEY];
	[self registHotkeysFromDefaults];
}

- (void)applicationWillTerminate
{
	[_hotkey_register unregistAll];
}

#pragma mark -
#pragma mark Window Delegate
- (void)windowWillClose:(NSNotification *)notification
{
	[_hotkey_text endEdit];
}
- (BOOL)windowShouldClose:(id)window
{
//	NSLog(@"- (BOOL)windowShouldClose:(id)window");
	return YES;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
//	NSLog(@"- (void)windowDidResignKey:(NSNotification *)notification");
}

- (void)windowWillMove:(NSNotification *)notification
{
//	NSLog(@"- (void)windowWillMove:(NSNotification *)notification");
}
- (void)windowDidBecomeKey:(NSNotification *)notification
{
	NSString* item_identifier = [_toolbar selectedItemIdentifier];
	
	if ([item_identifier isEqualToString:TOOLBAR_GENERAL]) {
		[self updateToolbarOnGeneral];
	}
}



#pragma mark -
#pragma mark Autostart on login
- (BOOL)isEnableLoginItem
{
	BOOL is_enable = NO;
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	
	UInt32 seedValue;
	NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in loginItemsArray)
	{		
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr)
		{
			if ([[(NSURL *)url path] hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
				is_enable = YES;
				break;
			}
		}
	}
	[loginItemsArray release];
	CFRelease(loginItems);
	
	return is_enable;
}


- (void)enableLoginItem
{
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];
	
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);		
	if (item)
	{
		CFRelease(item);
	}
	CFRelease(loginItems);
}

- (void)disableLoginItem
{
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	UInt32 seedValue;
	NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in loginItemsArray)
	{		
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr)
		{
			if ([[(NSURL *)url path] hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
				LSSharedFileListItemRemove(loginItems, itemRef);
				break;
			}
		}
	}
	[loginItemsArray release];
	CFRelease(loginItems);
}

- (IBAction)clickAutostartCheckbox:(id)sender
{
	if ([sender intValue] == 1) {
		// add
		[self enableLoginItem];
	} else {
		// remove
		[self disableLoginItem];
	}
}	

- (void)updateToolbarOnGeneral
{
	if ([self isEnableLoginItem]) {
		[_autostart_checkbox setIntValue:1];
	} else {
		[_autostart_checkbox setIntValue:0];
	}
}


@end
