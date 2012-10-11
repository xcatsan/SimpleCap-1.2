//
//  HandlerFactory.m
//  SimpleCap
//
//  Created by - on 08/03/16.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "HandlerFactory.h"

#import "WindowHandler.h"
#import "TrackWindowHandler.h"
#import "SelectionHandler.h"
#import "ScreenHandler.h"
#import "MenuHandler.h"
#import "ApplicationHandler.h"
#import "WidgetHandler.h"

#import "Handler.h"

@implementation HandlerFactory

- (id)initWithCaptureController:(CaptureController*)capture_controller
{
	self = [super init];
	if (self) {
		_handlers = [[NSMutableDictionary alloc] init];
		_capture_controller = [capture_controller retain];
	}
	return self;
}

- (void) dealloc
{
	[_handlers release];
	[_capture_controller release];
	[super dealloc];
}


- (Handler*)handlerWithName:(NSString*)name
{
	Handler* handler = (Handler*)[_handlers objectForKey:name];
	if (!handler) {
		if ([name isEqualToString:CAPTURE_WINDOW]) {
			handler = [[WindowHandler alloc] initWithCaptureController:_capture_controller];
			[_handlers setObject:handler forKey:name];
			
		} else if ([name isEqualToString:CAPTURE_TRACKWINDOW]) {
				handler = [[TrackWindowHandler alloc] initWithCaptureController:_capture_controller];
				[_handlers setObject:handler forKey:name];
			
		} else if ([name isEqualToString:CAPTURE_SELECTION]) {
			handler = [[SelectionHandler alloc] initWithCaptureController:_capture_controller];
			[_handlers setObject:handler forKey:name];

		} else if ([name isEqualToString:CAPTURE_SCREEN]) {
			handler = [[ScreenHandler alloc] initWithCaptureController:_capture_controller];
			[_handlers setObject:handler forKey:name];

		} else if ([name isEqualToString:CAPTURE_MENU]) {
			handler = [[MenuHandler alloc] initWithCaptureController:_capture_controller];
			[_handlers setObject:handler forKey:name];

		} else if ([name isEqualToString:CAPTURE_APPLICATION]) {
			handler = [[ApplicationHandler alloc] initWithCaptureController:_capture_controller];
			[_handlers setObject:handler forKey:name];
			
		} else if ([name isEqualToString:CAPTURE_WIDGET]) {
			handler = [[WidgetHandler alloc] initWithCaptureController:_capture_controller];
			[_handlers setObject:handler forKey:name];
		}
				
		[handler setup];
		[handler release];
	}
	return handler;
}

@end
