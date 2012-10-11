//
//  SelectionHistory.h
//  SimpleCap
//
//  Created by - on 08/10/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SelectionHistory : NSObject {

	NSMutableArray* _history_list;
}
+ (SelectionHistory*)selectionHistory;
- (void)setSize:(NSSize)size;
- (NSSize)sizeAtIndex:(int)index;
- (NSArray*)menuList;

@end
