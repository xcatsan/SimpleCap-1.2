//
//  HandlerFactory.h
//  SimpleCap
//
//  Created by - on 08/03/16.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CaptureType.h"

@class Handler;
@class CaptureController;

@interface HandlerFactory : NSObject {
	NSMutableDictionary *_handlers;
	CaptureController *_capture_controller;
}

- (id)initWithCaptureController:(CaptureController*)capture_controller;
- (Handler*)handlerWithName:(NSString*)name;
@end
