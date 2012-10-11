//
//  WindowHandler.m
//  SimpleCap
//
//  Created by - on 08/06/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "ImageFormat.h"
#import "UserDefaults.h"

@implementation ImageFormat
+ (NSString*)imageFormatDescription
{
	int image_format = [[UserDefaults valueForKey:UDKEY_IMAGE_FORMAT] intValue];
	return [self imageFormatDescriptionWith:image_format];
}

+ (NSString*)imageFormatDescriptionWith:(int)image_format
{
	NSString* imageFormatDescription;
	switch (image_format) {
		case IMAGEFORMAT_PNG:
			imageFormatDescription = @"PNG";
			break;
		case IMAGEFORMAT_GIF:
			imageFormatDescription = @"GIF";
			break;
		case IMAGEFORMAT_JPEG:
			imageFormatDescription = @"JPEG";
			break;
		case IMAGEFORMAT_CLIPBOARD:
			imageFormatDescription = @"COPY";
			break;
	}
	return imageFormatDescription;
}

// p.x is center point (not left point)
#define IMAGEFORMAT_PADDING_X 3.0
#define IMAGEFORMAT_PADDING_Y 1.5
+ (void)drawImageFormatDisplayAt:(NSPoint)p
{
	NSString *imageFormatStr = [self imageFormatDescription];
	NSMutableDictionary *stringAttributes = [NSMutableDictionary dictionary];
	
	[stringAttributes setObject:[NSFont boldSystemFontOfSize:10.0]
						 forKey: NSFontAttributeName];
	[stringAttributes setObject:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0]
						 forKey:NSForegroundColorAttributeName];
	
	NSSize fontSize = [imageFormatStr sizeWithAttributes:stringAttributes];
	
	NSPoint drawPoint = p;
	drawPoint.x -= fontSize.width/2.0;
	drawPoint.y += IMAGEFORMAT_PADDING_Y;
	
	NSRect backgroundRect = NSZeroRect;
	backgroundRect.origin.x = drawPoint.x - IMAGEFORMAT_PADDING_X;
	backgroundRect.origin.y = p.y;
	backgroundRect.size.width = fontSize.width + IMAGEFORMAT_PADDING_X*2;
	backgroundRect.size.height = fontSize.height + IMAGEFORMAT_PADDING_Y*2;
	
	//	[[NSColor colorWithDeviceWhite:0.0 alpha:0.2] set];
	//	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:4.0 yRadius:4.0];
	//	[path fill];
	//	NSRectFill(backgroundRect);
	
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(2.0, -2.0)];
	[shadow setShadowBlurRadius:0.5];
	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
	
	[NSGraphicsContext saveGraphicsState];
	[shadow set];
	[imageFormatStr drawAtPoint:drawPoint withAttributes: stringAttributes];
	[NSGraphicsContext restoreGraphicsState];
}

@end