//
//  PreferedApplications.m
//  FindingAllApps
//
//  Created by - on 08/10/29.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationMenu.h"
#import "UserDefaults.h"

//---------------------------------------------------------------------------
@interface AppEntry : NSObject
{
	NSString* _path;
	NSString* _name;
	NSImage* _image;
}
@property (retain) NSString* path;
@property (retain) NSString* name;
@property (retain) NSImage* image;

-(id)initWithPath:(NSString*)path;
@end

@implementation AppEntry
@synthesize path = _path;
@synthesize name = _name;
@synthesize image = _image;

-(id)initWithPath:(NSString*)app_path
{
	self = [super init];
	if (self) {
		_path = [app_path retain];
		
		LSCopyDisplayNameForURL((CFURLRef)[NSURL fileURLWithPath:_path], (CFStringRef *)&_name);
		_image = [[[NSWorkspace sharedWorkspace] iconForFile:_path] retain];
		[_image setSize:NSMakeSize(16, 16)];
	}
	return self;
}
- (void) dealloc
{
	[_path release];
	[_name release];
	[_image release];
	[super dealloc];
}

- (NSComparisonResult)compare:(AppEntry*)entry
{
	return [_name compare:entry.name];
}
@end

//---------------------------------------------------------------------------
@implementation ApplicationMenu

- (NSMenuItem*)menuItemWithAppEntry:(AppEntry*)entry
{
	NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:entry.name];
	[item setImage:entry.image];
	[item setTarget:_delegate];
	[item setAction:@selector(openWithApplication:)];
	[item setRepresentedObject:
	 [NSDictionary dictionaryWithObjectsAndKeys:entry.path, @"path", nil]];
	return item;
}

- (void)createMenuItemsWithTargetPath:(NSString*)target_path
{
	// *not be used* 2009-02-23
	NSURL* target_url = [NSURL fileURLWithPath:target_path];
	NSMutableArray* item_list = [NSMutableArray array];
	AppEntry* entry;
	NSString* path;

	// (1) default application
	FSRef outAppRef;
	NSURL* default_url = nil;

	LSGetApplicationForURL((CFURLRef)target_url, kLSRolesAll, &outAppRef, (CFURLRef*)&default_url);
	entry = [[[AppEntry alloc] initWithPath:[default_url path]] autorelease];
	[item_list addObject:[self menuItemWithAppEntry:entry]];

	path = @"/Applications/Mail.app";
	entry = [[[AppEntry alloc] initWithPath:path] autorelease];
	[item_list addObject:[self menuItemWithAppEntry:entry]];
		
	// (-) separator
	[item_list addObject:[NSMenuItem separatorItem]];
	

	// (2) preffered applications
	NSArray* app_list = [(NSArray*)LSCopyApplicationURLsForURL((CFURLRef)target_url, kLSRolesAll) autorelease];
	
	NSMutableArray* entry_list = [NSMutableArray array];
	
	for (NSURL* url in app_list) {
		if ([url isEqual:default_url]) {
			continue;
		}
		entry = [[[AppEntry alloc] initWithPath:[url path]] autorelease];
		[entry_list addObject:entry];
	}
	
	NSArray* sorted_entry_list = [entry_list sortedArrayUsingSelector:@selector(compare:)];
	
	if (_prefered_menu) {
		[_prefered_menu release];
	}
	_prefered_menu = [[NSMenu alloc] initWithTitle:@"Prefered Applications"];
	for (AppEntry* entry in sorted_entry_list) {
		[_prefered_menu addItem:[self menuItemWithAppEntry:entry]];
	}
	[default_url release];
	_prefered_menu_item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"AppMenuOther", @"")
													  action:nil
											   keyEquivalent:@""] autorelease];
	[item_list addObject:_prefered_menu_item];

	_menu_items = [item_list retain];
}

- (id)initWithTargetPath:(NSString*)path Delegate:(id)delegate;
{
	self = [super init];
	if (self) {
		_delegate = [delegate retain];
//		[self createMenuItemsWithTargetPath:path];
	}
	return self;
}
- (void) dealloc
{
	[_delegate release];
	[_menu_items release];
	[super dealloc];
}

- (NSArray*)menuItems
{
	return _menu_items;
}

- (NSInteger)indexForPath:(NSString*)path
{
	NSInteger index = 0;
	for (NSMenuItem* item in _menu_items) {
		NSDictionary* dict = [item representedObject];
		NSString* item_path = [dict objectForKey:@"path"];
		if ([item_path isEqualToString:path]) {
			break;
		}
		index++;
	}
	return index;
	// not found: return 0
}

- (NSString*)pathAtIndex:(NSInteger)index
{
	NSMenuItem* item = [_menu_items objectAtIndex:index];
	NSDictionary* dict = [item representedObject];
	return [dict objectForKey:@"path"];
}

-(NSMenu*)menu
{
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Application Menu"] autorelease];
	NSString* path;
	AppEntry* entry;

	// (1) preest applications
	path = [UserDefaults valueForKey:UDKEY_APPLICATION1];
	if (path) {
		entry = [[[AppEntry alloc] initWithPath:path] autorelease];
		[menu addItem:[self menuItemWithAppEntry:entry]];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION2];
	if (path) {
		entry = [[[AppEntry alloc] initWithPath:path] autorelease];
		[menu addItem:[self menuItemWithAppEntry:entry]];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION3];
	if (path) {
		entry = [[[AppEntry alloc] initWithPath:path] autorelease];
		[menu addItem:[self menuItemWithAppEntry:entry]];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION4];
	if (path) {
		entry = [[[AppEntry alloc] initWithPath:path] autorelease];
		[menu addItem:[self menuItemWithAppEntry:entry]];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION5];
	if (path) {
		entry = [[[AppEntry alloc] initWithPath:path] autorelease];
		[menu addItem:[self menuItemWithAppEntry:entry]];
	}
	
	// (-) separator
	[menu addItem:[NSMenuItem separatorItem]];

	// open preferences
	NSString* title = NSLocalizedString(@"MenuSetupApplications", @"");
	NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:title
									   action:@selector(openPereferecesWindow:)
								keyEquivalent:@""] autorelease];
	[item setTarget:_delegate];
	[item setRepresentedObject:[NSNumber numberWithInt:3]];		// 3->Preference Tab:3 (viewer option)
	[menu addItem:item];
	
	/*
	// (-) separator
	[menu addItem:[NSMenuItem separatorItem]];

	// (2) prefered applications
	for (NSMenuItem* item in _menu_items) {
		[menu addItem:item];
	}

	[menu setSubmenu:_prefered_menu forItem:_prefered_menu_item];
	*/
	return menu;
}

@end
