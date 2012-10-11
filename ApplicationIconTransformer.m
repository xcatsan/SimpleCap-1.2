//
//  ApplicationIconTransformer.m
//  SimpleCap
//
//  Created by - on 09/01/13.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationIconTransformer.h"


@implementation ApplicationIconTransformer

+ (Class)transformedValueClass
{
    return [NSImage class];
}

- (id)transformedValue:(id)value
{
	if (!value) {
		return  nil;
	}
	return [[NSWorkspace sharedWorkspace] iconForFile:value];
}

@end
