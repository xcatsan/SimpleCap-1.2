//
//  CoordinateConverter.m
//  SimpleCap
//
//  Created by - on 09/03/29.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "CoordinateConverter.h"
#import "Screen.h"

@implementation CoordinateConverter


+ (NSPoint)convertFromLocalToCGWindowPoint:(NSPoint)from_p
{
	CGFloat cx1, cy1, lx1, ly1, sx1, sy2;
	NSRect frame = [[Screen defaultScreen] frame];
	NSRect m_frame = [[[NSScreen screens] objectAtIndex:0] frame];
	
	CGFloat sh = m_frame.size.height;
	lx1 = from_p.x;
	ly1 = from_p.y;
	sx1 = frame.origin.x;
	sy2 = frame.origin.y + frame.size.height;
	
	cx1 = lx1 + sx1;
	cy1 = ly1 - (sy2 - sh);
	
	return NSMakePoint(cx1, cy1);
}

+ (NSPoint)convertFromCGWindowPointToLocal:(NSPoint)from_p
{
	CGFloat cx1, cy1, lx1, ly1, sx1, sy2;
	NSRect frame = [[Screen defaultScreen] frame];
	NSRect m_frame = [[[NSScreen screens] objectAtIndex:0] frame];

	CGFloat sh = m_frame.size.height;
	cx1 = from_p.x;
	cy1 = from_p.y;
	sx1 = frame.origin.x;
	sy2 = frame.origin.y + frame.size.height;
	
	lx1 = cx1 - sx1;
//TODO	ly1 = cy1 + (sy2 - sh);
	ly1 = cy1 + fabsf(sy2 - sh);
	return NSMakePoint(lx1, ly1);
}
@end
