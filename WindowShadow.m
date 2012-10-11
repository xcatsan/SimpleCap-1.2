//
//  WindowShadow.m
//  SimpleCap
//
//  Created by - on 08/07/26.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "WindowShadow.h"

static NSSize _offset;
static NSSize _size;

@implementation WindowShadow

+ (void)initialize
{
	_offset = NSMakeSize(40, 20);
	_size = NSMakeSize(80, 80);
}

+ (NSSize)offset
{
	return _offset;
}

+ (NSSize)size
{
	return _size;
}

+ (CGRect)addShadowSizeToCGRect:(CGRect)cgrect
{
	cgrect.origin.x -= _offset.width;
	cgrect.origin.y -= _offset.height;
	cgrect.size.width += _size.width;
	cgrect.size.height += _size.height;
	return cgrect;
}
+ (CGRect)subShadowSizeToCGRect:(CGRect)cgrect
{
	cgrect.origin.x -= _offset.width;
	cgrect.origin.y -= _offset.height;
	cgrect.size.width -= _size.width;
	cgrect.size.height -= _size.height;
	return cgrect;
}


@end
