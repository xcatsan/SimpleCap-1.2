//
//  SimpleViewerBackgroundView.m
//  SimpleCap
//
//  Created by - on 09/01/17.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerBackgroundView.h"
#import "UserDefaults.h"
#import <QuartzCore/QuartzCore.h>

@implementation SimpleViewerBackgroundView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[UserDefaults addObserver:self forKey:UDKEY_VIEWER_BACKGROUND];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[self setNeedsDisplay:YES];
}

- (void) dealloc
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:UDKEY_VIEWER_BACKGROUND];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
	
	int background = [[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue];
	if (background == 1) {
		CIFilter *filter = [CIFilter filterWithName:@"CICheckerboardGenerator"];
		[filter setDefaults];
		
		[filter setValue:[NSNumber numberWithInt:10] forKey:@"inputWidth"];
		[filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
				  forKey:@"inputColor0"];
		[filter setValue:[CIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]
				  forKey:@"inputColor1"];
		
		CIImage *ciimage = [filter valueForKey:kCIOutputImageKey];
		
		CIContext *context = [[NSGraphicsContext currentContext] CIContext];
		
		[context drawImage:ciimage
				   atPoint:CGPointZero
				  fromRect:NSRectToCGRect([self bounds])];
	} else if (background == 2) {
		[[NSColor whiteColor] set];
		NSRectFill(rect);
	}
}

@end
