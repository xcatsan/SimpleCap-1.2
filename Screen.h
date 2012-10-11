//
//  Screen.h
//  SimpleCap
//
//  Created by - on 08/07/27.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Screen : NSObject {
	NSRect _frame;
	NSRect _menu_frame;
}
+ (Screen*)defaultScreen;
- (NSRect)frame;
- (NSRect)menuScreenFrame;
- (CGRect)frameInCGCoordinate;

@end
