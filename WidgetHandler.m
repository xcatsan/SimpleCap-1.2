//
//  WidgetHandler.m
//  SimpleCap
//
//  Created by - on 08/07/05.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "WidgetHandler.h"
#import "Window.h"

@implementation WidgetHandler

- (Window*)topWindow
{
	Window* top_window = nil;
	for (Window* window in [self getWindowList]) {
		if ([window isWidget]) {
			NSRect rect = [window rect];
			if (rect.size.width > 16.0 && rect.size.height > 16.0) {
				top_window = window;
				break;
			}
		}
	}
	return top_window;
}

- (BOOL)isTargetWindow:(Window*)window
{
	return [window isWidget];
}

@end
