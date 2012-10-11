//
//  WindowUtility.m
//  SimpleCap
//
//  Created by - on 09/01/03.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "DesktopWindow.h"

@implementation DesktopWindow

static DesktopWindow* _desktop_window = nil;

+ (DesktopWindow*)sharedDesktopWindow
{
	if (!_desktop_window) {
		_desktop_window = [[DesktopWindow alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:_desktop_window
												 selector:@selector(screenChanged:)
													 name:NSApplicationDidChangeScreenParametersNotification
												   object:nil];
		[_desktop_window update];
	}
	return _desktop_window;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_id_list release];
	[super dealloc];
}

- (void)update
{
	CFArrayRef ar = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
	CFDictionaryRef window;
	CFIndex i;
	CGWindowID wid;

	[_id_list release];
	_id_list = [[NSMutableArray alloc] init];

	for (i=0; i < CFArrayGetCount(ar); i++) {
		window = CFArrayGetValueAtIndex(ar, i);
		NSString* name = (NSString*)CFDictionaryGetValue(window, kCGWindowName);
		NSString* owner_name = (NSString*)CFDictionaryGetValue(window, kCGWindowOwnerName);
		if ([name isEqualToString:@"Desktop"] && [owner_name isEqualToString:@"Window Server"]) {
			CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber),
							 kCGWindowIDCFNumberType, &wid);
			[_id_list addObject:[NSNumber numberWithUnsignedInt:wid]];
		}
	}
}

- (NSArray*)CGWindowIDlist
{
	return _id_list;
}

- (void)screenChanged:(NSNotification *)notification
{
	[self update];
}

@end
