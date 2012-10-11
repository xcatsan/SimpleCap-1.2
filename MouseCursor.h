//
//  MouseCursor.h
//  MousePointer-3
//
//  Created by - on 08/07/20.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MouseCursor : NSObject {

	NSImage*	_image;
	NSPoint		_location;
	NSPoint		_hot_spot;
}
+ (MouseCursor*)mouseCursor;
- (NSImage*)image;
- (NSSize)size;
- (NSPoint)location;
- (NSPoint)hotSpot;
- (NSPoint)pointForDrawing;

- (BOOL)isIntersectsRect:(NSRect)rect;
@end
