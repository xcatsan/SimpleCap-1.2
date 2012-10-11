//
//  MenuHandler.h
//  SimpleCap
//
//  Created by - on 08/05/31.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"

@interface MenuHandler : HandlerBase <Handler, TimerClient>  {
	BOOL _is_menu_only;
}

@end
