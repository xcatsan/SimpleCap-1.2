//
//  TimerScreen.h
//  SimpleCap
//
//  Created by - on 08/03/23.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"

@interface ScreenHandler : HandlerBase <Handler, TimerClient> {
	
}
@end
