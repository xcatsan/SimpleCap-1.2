//
//  ApplicationHandler.h
//  SimpleCap
//
//  Created by - on 08/07/02.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"

@class ThinButtonBar;
@interface ApplicationHandler : HandlerBase <Handler, TimerClient> {

	ThinButtonBar*	_button_bar;
	NSMutableArray* _app_windows;
	id _application;
}
@end
