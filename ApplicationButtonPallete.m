//
//  ButtonPallete.m
//  MatrixSample
//
//  Created by - on 09/12/08.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationButtonPallete.h"
#import "ApplicationButtonCell.h"
#import "ApplicationButtonMatrix.h"
#import "UserDefaults.h"

#define LAYOUT_MARGIN	3.0

@implementation ApplicationButtonPallete

@synthesize target, action;

#pragma mark -
#pragma mark Utility
-(void)updateApplications
{
	NSString* path;
	path = [UserDefaults valueForKey:UDKEY_APPLICATION1];
	if (path) {
		[self addButtonWithPath:path];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION2];
	if (path) {
		[self addButtonWithPath:path];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION3];
	if (path) {
		[self addButtonWithPath:path];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION4];
	if (path) {
		[self addButtonWithPath:path];
	}
	
	path = [UserDefaults valueForKey:UDKEY_APPLICATION5];
	if (path) {
		[self addButtonWithPath:path];
	}
	
}

-(void)registObservers
{
	[UserDefaults addObserver:self forKey:UDKEY_APPLICATION1];
	[UserDefaults addObserver:self forKey:UDKEY_APPLICATION2];
	[UserDefaults addObserver:self forKey:UDKEY_APPLICATION3];
	[UserDefaults addObserver:self forKey:UDKEY_APPLICATION4];
	[UserDefaults addObserver:self forKey:UDKEY_APPLICATION5];
}
-(void)unregistObservers
{
	[UserDefaults removeObserver:self forKey:UDKEY_APPLICATION1];
	[UserDefaults removeObserver:self forKey:UDKEY_APPLICATION2];
	[UserDefaults removeObserver:self forKey:UDKEY_APPLICATION3];
	[UserDefaults removeObserver:self forKey:UDKEY_APPLICATION4];
	[UserDefaults removeObserver:self forKey:UDKEY_APPLICATION5];
}	

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[self removeAll];
	[self updateApplications];
}

#pragma mark -
#pragma mark Initialize and Deallocation
-(id)init
{
	self = [super init];
	
	if (self) {
		matrix = [[[ApplicationButtonMatrix alloc] init] autorelease];
		[matrix setTarget:self];
		[matrix setAction:@selector(click:)];
		[self registObservers];
		[self updateApplications];
	}
	return self;
}
- (void) dealloc
{
	matrix = nil;
	[self unregistObservers];
	[super dealloc];
}

#pragma mark -
#pragma mark Managing Cell
-(void)addButtonWithPath:(NSString*)path
{
	ApplicationButtonCell* cell = [ApplicationButtonCell cellWithPath:path];
	NSArray* array = [NSArray arrayWithObject:cell];
	[matrix addRowWithCells:array];
	[matrix sizeToCells];
	[matrix setToolTip:cell.name forCell:cell];
	[self updateLayout];
}
-(void)removeAll
{
	NSInteger row;
	for (row=[matrix numberOfRows]-1; row >=0; row--) {
		[matrix removeRow:row];
	}
}


#pragma mark -
#pragma mark Event Handling
-(void)click:(id)sender
{
	ApplicationButtonCell* selectedCell = [sender selectedCell];
	NSInteger row, column;
	[matrix getRow:&row column:&column ofCell:selectedCell];

	NSMethodSignature* signature = [[target class] instanceMethodSignatureForSelector:self.action];
	if (signature) {
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setSelector:self.action];
		[invocation setTarget:self.target];
		[invocation setArgument:&row atIndex:2];
		[invocation setArgument:&selectedCell atIndex:3];
		[invocation invoke];
	}
}

#pragma mark -
#pragma mark Public method
-(void)addToView:(NSView*)view
{
	[view addSubview:matrix];
//	[view addSubview:matrix positioned:NSWindowBelow relativeTo:nil];
	contentView = view;			// only assign
}

-(void)setOrigin:(NSPoint)point
{
	[matrix setFrameOrigin:point];
}

-(void)updateLayout
{
	NSSize matrix_size = [matrix frame].size;
	NSSize view_size = [contentView frame].size;
	NSPoint origin = NSZeroPoint;
	origin.y = view_size.height - matrix_size.height - LAYOUT_MARGIN;
//	origin.y = 54 + LAYOUT_MARGIN;
	origin.x = view_size.width - matrix_size.width - LAYOUT_MARGIN;
	[self setOrigin:origin];
}

@end
