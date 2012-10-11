//
//  FukidashiController.h
//  Fukidashi
//
//  Created by - on 08/12/06.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FukidashiWindow;
@class FukidashiView;
@interface FukidashiController : NSObject {

	FukidashiWindow* _window;
	FukidashiView* _view;
	
	int _state;
	NSTimer* _timer;
	int _count;
	int _showtime;
	
	NSPoint _base_position;
}

+(FukidashiController*)sharedConroller;
- (void)showMessage:(NSString*)message At:(NSPoint)p;
- (void)showMessage:(NSString*)message;
- (void)setBasePosition:(NSPoint)p;
- (void)setShowTime:(int)showtime;
@end
