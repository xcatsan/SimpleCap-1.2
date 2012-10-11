//
//  WindowUtility.h
//  SimpleCap
//
//  Created by - on 09/01/03.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DesktopWindow : NSObject {

	NSMutableArray* _id_list;
}

+ (DesktopWindow*)sharedDesktopWindow;
- (NSArray*)CGWindowIDlist;
- (void)update;

@end
