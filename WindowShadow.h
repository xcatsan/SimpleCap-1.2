//
//  WindowShadow.h
//  SimpleCap
//
//  Created by - on 08/07/26.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WindowShadow : NSObject {
}
+ (NSSize)offset;
+ (NSSize)size;
+ (CGRect)addShadowSizeToCGRect:(CGRect)cgrect;
+ (CGRect)subShadowSizeToCGRect:(CGRect)cgrect;

@end
