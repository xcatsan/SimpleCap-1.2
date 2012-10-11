//
//  Window.m
//  SimpleCap
//
//  Created by - on 08/07/05.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "Window.h"
#import "WindowLayer.h"
#import "CoordinateConverter.h"

@implementation Window
- (id)initWithWindowDictionaryRef:(CFDictionaryRef)window
{
	self = [super init];
	if (self) {
		CGRect cgrect;

		CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber),
						 kCGWindowIDCFNumberType, &_window_id);
		CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowOwnerPID),
						 kCFNumberIntType, &_owner_pid);
		CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowLayer),
						 kCFNumberIntType, &_layer);
		CFNumberRef workspace = CFDictionaryGetValue(window, kCGWindowWorkspace);
		if (workspace) {
			CFNumberGetValue(workspace, kCFNumberIntType, &_workspace);
		} else {
			_workspace = 0;
		}
		CGRectMakeWithDictionaryRepresentation(CFDictionaryGetValue(window, kCGWindowBounds), &cgrect);
		_window_name = (NSString*)CFDictionaryGetValue(window, kCGWindowName);
		_owner_name = (NSString*)CFDictionaryGetValue(window, kCGWindowOwnerName);

		[_window_name retain];
		[_owner_name retain];

		_rect = NSRectFromCGRect(cgrect);
		_rect.origin = [CoordinateConverter convertFromCGWindowPointToLocal:_rect.origin];
	}
	return self;
}

- (BOOL)isEqual:(id)anObject
{
	if (anObject == self) {
		return YES;
	}
	if (!anObject || ![anObject isKindOfClass:[self class]]) {
		return NO;
	}
	if (_window_id != [anObject windowID]) {
		return NO;
	}
	return YES;
}
-(int)order {
	return _order;
}
-(void)setOrder:(int)order
{
	_order = order;
}
-(CGWindowID)windowID {
	return _window_id;
}
-(NSNumber*)numberWindowID
{
	return [NSNumber numberWithInt:_window_id];
}

-(int)ownerPID
{
	return _owner_pid;
}
-(NSString*)windowName
{
	return _window_name;
}
-(NSString*)ownerName
{
	return _owner_name;
}
-(int)layer
{
	return _layer;
}

-(NSRect)rect
{
	return _rect;
}
-(CGRect)cgrect
{
	return NSRectToCGRect(_rect);
}
-(int)workspace
{
	return _workspace;
}

-(void)setRect:(NSRect)rect
{
	_rect = rect;
}

- (void)updateImage
{
	if (_image) {
		[_image release];
	}
	NSRect rect = _rect;
	rect.origin = [CoordinateConverter convertFromLocalToCGWindowPoint:rect.origin];
	CGImageRef cgimage = CGWindowListCreateImage(NSRectToCGRect(rect),
												 kCGWindowListOptionIncludingWindow, _window_id, kCGWindowImageDefault);
	NSBitmapImageRep *bitmap_rep = [[NSBitmapImageRep alloc] initWithCGImage:cgimage];
	_image = [[NSImage alloc] init];
	[_image addRepresentation:bitmap_rep];
	[bitmap_rep release];
}

-(NSImage*)image
{
	if (!_image) {
		[self updateImage];
	}		
	return _image;
}
-(NSString*)description
{
	return [NSString stringWithFormat:@"[%d] %d: %d: (%d): %@: %@", _window_id, _order, _owner_pid, _workspace, NSStringFromRect(_rect), _window_name];
}
- (NSComparisonResult)compare:(Window*)wn
{
	int order = [wn order];
	if (_order < order) {
		return NSOrderedAscending;
	} else if (_order > order) {
		return NSOrderedDescending;
	}
	return NSOrderedSame;
}

- (void) dealloc
{
	if (_image) {
		[_image release];
	}
	[_window_name release];
	[_owner_name release];
	[super dealloc];
}

- (BOOL)isSpotlight
{
	return (_layer == SC_LAYER_SPOTLIGHT) ? YES : NO;
}

- (BOOL)isDock
{
	return [_owner_name isEqualToString:@"Dock"];
}

- (BOOL)isWidget
{
	if ([self isDock] && _layer == SC_LAYER_DOCK) {
		return YES;
	}
	return NO;
}

- (BOOL)isNormalWindow:(BOOL)normal
{
	if ([self isDock]) {
		return NO;
	}
	
	if (normal && _layer == kCGNormalWindowLevel) {
		return YES;
	}
	
	if (!normal && _layer < kCGMainMenuWindowLevel) {
		return YES;
	}
	return NO;
}
+ (NSRect)unionNSRectWithWindowList:(NSArray*)list
{
	NSRect all_rect = NSZeroRect;
	NSRect rect;
	for(Window* window in list) {
		rect = [window rect];
		if (NSEqualRects(all_rect, NSZeroRect)) {
			all_rect = rect;
		} else {
			all_rect = NSUnionRect(all_rect, rect);
		}
	}
	all_rect.origin = [CoordinateConverter convertFromLocalToCGWindowPoint:all_rect.origin];
	return all_rect;
}

+ (CGRect)unionCGRectWithWindowList:(NSArray*)list
{
	return NSRectToCGRect([Window unionNSRectWithWindowList:list]);
}


+ (Window*)statusBarWindow
{
	CFArrayRef ar = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
	CFDictionaryRef window_ref;
	CFIndex i;
	int status_bar_pid = [[NSProcessInfo processInfo] processIdentifier];
	int owner_pid;
	int layer;
	
	for (i=0; i < CFArrayGetCount(ar); i++) {
		window_ref = CFArrayGetValueAtIndex(ar, i);
		CFNumberGetValue(CFDictionaryGetValue(window_ref, kCGWindowOwnerPID),
						 kCFNumberIntType, &owner_pid);
		CFNumberGetValue(CFDictionaryGetValue(window_ref, kCGWindowLayer),
						 kCFNumberIntType, &layer);
		if (owner_pid == status_bar_pid && layer == kCGStatusWindowLevel) {
			break;
		}
	}
	Window* window = [[[Window alloc] initWithWindowDictionaryRef:window_ref] autorelease];
	CFRelease(ar);
	
	return window;
}

@end
