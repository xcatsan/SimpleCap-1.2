//
//  ImageFormat.h
//  SimpleCap
//
//  Created by - on 10/01/11.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define IMAGEFORMAT_PNG			0
#define IMAGEFORMAT_GIF			1
#define IMAGEFORMAT_JPEG		2
#define IMAGEFORMAT_CLIPBOARD	10

@interface ImageFormat : NSObject {
	
}

+ (NSString*)imageFormatDescription;
+ (NSString*)imageFormatDescriptionWith:(int)image_format;
+ (void)drawImageFormatDisplayAt:(NSPoint)p;

@end

