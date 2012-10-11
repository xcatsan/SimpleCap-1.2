//
//  CoordinateConverter.h
//  SimpleCap
//
//  Created by - on 09/03/29.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CoordinateConverter : NSObject {

}
+ (NSPoint)convertFromLocalToCGWindowPoint:(NSPoint)from_p;
+ (NSPoint)convertFromCGWindowPointToLocal:(NSPoint)from_p;

@end
