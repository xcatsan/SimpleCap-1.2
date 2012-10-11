//
//  SimpleViewerImageSubView.h
//  SimpleCap
//
//  Created by - on 09/01/04.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleViewerImageSubView : NSView {

	NSImage* _image;
	NSImageInterpolation _interpolation;
}

- (void)setImage:(NSImage*)image;
- (NSImage*)image;
- (CGFloat)reductionRatio;

@end
