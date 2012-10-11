//
//  TimerWindowView.h
//  TimerDialog-01
//
//  Created by - on 08/06/08.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TimerController;
@interface TimerWindowView : NSView {

	TimerController* _controller;
	NSShadow* _shadow;
}
- (void)setTimerController:(TimerController*)controller;
@end
