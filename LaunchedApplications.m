//
//  LaunchedApplications.m
//  SimpleCap
//
//  Created by - on 08/07/02.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "LaunchedApplications.h"


@implementation LaunchedApplications

- (id)initWithDelegate:(id)delegate
{
	self = [super init];
	if (self) {
		_delegate = [delegate retain];
	}
	return self;
}

- (void) dealloc
{
	[_delegate release];
	[super dealloc];
}


- (void)clearMenu:(NSMenu*)menu
{
	NSInteger i;
	NSInteger num = [menu numberOfItems];
	for (i=0; i < num; i++) {
		[menu removeItemAtIndex:0];
	}
}

-(void)updateApplicationMenu:(NSMenu*)menu
{
	[self clearMenu:menu];
	NSWorkspace* ws = [NSWorkspace sharedWorkspace];
	for (NSDictionary* app in [ws launchedApplications]) {
		NSString* name = [app objectForKey:@"NSApplicationName"];
		NSImage* image = [ws iconForFile:[app objectForKey:@"NSApplicationPath"]];
		NSNumber *pid = [app objectForKey:@"NSApplicationProcessIdentifier"];
		[image setSize:NSMakeSize(16, 16)];

		NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:name];
		[item setImage:image];
		[item setTarget:_delegate];
		[item setAction:@selector(selectApplication:)];
		[item setRepresentedObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:
		  name, @"name", image, @"image", pid, @"pid", nil]];
		[menu addItem:item];
	}
}



@end
