//
//  TimerClient.h
//  SimpleCap
//
//  Created by - on 08/06/15.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

@class TimerController;
@protocol TimerClient
- (void)timerStarted:(TimerController*)controller;
- (void)timerCounted:(TimerController*)controller;
- (void)timerFinished:(TimerController*)controller;
- (void)timerCanceled:(TimerController*)controller;
- (void)timerPaused:(TimerController*)controller;
- (void)timerRestarted:(TimerController*)controller;
- (void)openConfigMenuWithView:(NSView*)view event:(NSEvent*)event;
@end


