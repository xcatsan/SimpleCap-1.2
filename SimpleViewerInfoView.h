//
//  SimpleViewInfoView.h
//  SimpleCap
//
//  Created by - on 08/12/21.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleViewerInfoView : NSView {

	CGFloat _ratio;
	CGFloat _last_size;
	NSDictionary* _attribute;
	
	NSString* _dir_info;
	CGFloat _dir_info_x;
}

- (void)setRatio:(CGFloat)ratio;
- (NSSize)infoStringSize;
- (void)setDirectoryInfomation:(NSString*)dir_info;
- (void)setDirInfoOffsetX:(CGFloat)x;
@end
